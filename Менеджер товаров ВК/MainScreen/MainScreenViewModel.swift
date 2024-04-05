//
//  MainScreenViewModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 26.03.2024.
//

import Foundation
import VKID

class MainScreenViewModel {
    
    let vkid: VKID
    var vkIdData = VkIdData(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    var albums: [Album] = []
    var products: [Product] = []
    var offset = 0
    var shouldLoadMore = true
    
    
    
    
    func fetchAlbums(completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.getAlbums", params: "owner_id=-\(VkIdData.currentGroupId!)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    // Разбор данных и создание массива подборок
                    var albums = [Album]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           let title = item["title"] as? String {
                            let album = Album(id: id, title: title)
                            albums.append(album)
                        }
                    }
                    self.albums = albums
                    // Вызываем замыкание для обработки завершения запроса
                    completion()
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    
    func fetchProducts(albumId: String ,completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.get", params: "owner_id=-\(VkIdData.currentGroupId!)\(albumId)&count=12&offset=\(offset)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    //Разбор данных и создание массива товаров
                    var products = [Product]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           let title = item["title"] as? String,
                           let priceObject = item["price"] as? [String: Any],
                           let price = priceObject["amount"] as? String,
                           let currencyObject = priceObject["currency"] as? [String: Any],
                           let currency = currencyObject["name"] as? String,
                           let imageUrlString = item["thumb_photo"] as? String,
                           let imageUrl = URL(string: imageUrlString),
                           let availability = item["availability"] as? Int {
                            let product = Product(id: id, title: title, price: price, currency: currency, imageUrl: imageUrl, availability: availability)
                            products.append(product)
                        }
                    }
                    self.offset += products.count
                    
                    if products.count < 12 {
                        self.shouldLoadMore = false
                    }
                    
                    self.products += products
                    
                    completion()
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    
    func search(q: String,completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.search", params: "owner_id=-\(VkIdData.currentGroupId!)&q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    var products = [Product]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           let title = item["title"] as? String,
                           let priceObject = item["price"] as? [String: Any],
                           let price = priceObject["amount"] as? String,
                           let currencyObject = priceObject["currency"] as? [String: Any],
                           let currency = currencyObject["name"] as? String,
                           let imageUrlString = item["thumb_photo"] as? String,
                           let imageUrl = URL(string: imageUrlString),
                           let availability = item["availability"] as? Int {
                            let product = Product(id: id, title: title, price: price, currency: currency, imageUrl: imageUrl, availability: availability)
                            products.append(product)
                        }
                    }
                    self.products = products
                    completion()
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
    
    
    
}

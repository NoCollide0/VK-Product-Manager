//
//  ProductScreenViewModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 02.04.2024.
//

import Foundation
import VKID

class ProductScreenViewModel {
    
    let vkid: VKID
    var vkIdData = VkIdData(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    
    
    
    func fetchProduct(completion: @escaping (ProductById?) -> Void) {
        vkIdData.apiRequest(method: "market.getById", params: "item_ids=-\(VkIdData.currentGroupId!)_\(VkIdData.currentProductId!)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    if let item = items.first {
                        if let id = item["id"] as? Int,
                           let title = item["title"] as? String,
                           let priceObject = item["price"] as? [String: Any],
                           let price = priceObject["amount"] as? String,
                           let currencyObject = priceObject["currency"] as? [String: Any],
                           let currency = currencyObject["name"] as? String,
                           let imageUrlString = item["thumb_photo"] as? String,
                           let imageUrl = URL(string: imageUrlString),
                           let description = item["description"] as? String,
                           let dateUnixtime = item["date"] as? TimeInterval,
                           let availability = item["availability"] as? Int {
                            let date = Date(timeIntervalSince1970: dateUnixtime)
                            let product = ProductById(id: id, title: title, price: price, currency: currency, imageUrl: imageUrl, availability: availability, description: description, date: date)
                            completion(product)
                        }
                    } else {
                        completion(nil)
                    }
                }
            case .failure(let error):
                print(error)
                completion(nil)
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


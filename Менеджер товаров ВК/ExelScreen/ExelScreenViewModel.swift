//
//  ExelScreenViewModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 04.04.2024.
//

import Foundation
import VKID
import xlsxwriter

class ExelScreenViewModel {
    
    let vkid: VKID
    var vkIdData = VkIdData(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    var albums: [ExelAlbum] = []
    var products: [ExelProduct] = []
    
    
    
    
    func fetchAlbums(completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.getAlbums", params: "owner_id=-\(VkIdData.currentGroupId!)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    // Разбор данных и создание массива подборок
                    var albums = [ExelAlbum]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           let title = item["title"] as? String {
                            let album = ExelAlbum(id: id, title: title)
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
    
    func fetchProducts(albumId: String, albumTitle: String, completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.get", params: "owner_id=-\(VkIdData.currentGroupId!)\(albumId)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    //Разбор данных и создание массива товаров
                    var products = [ExelProduct]()
                    for item in items {
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
                            let product = ExelProduct(id: id, title: title, price: price, currency: currency, imageUrl: imageUrl, availability: availability, description: description, date: date, albumTitle: albumTitle)
                            products.append(product)
                        }
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
    
    
    
    
    func fetchAllProducts(completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "market.get", params: "owner_id=-\(VkIdData.currentGroupId!)") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    var products = [ExelProduct]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           !self.products.contains(where: { $0.id == id }),  // Проверяем, не содержится ли продукт уже в массиве
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
                            let product = ExelProduct(id: id, title: title, price: price, currency: currency, imageUrl: imageUrl, availability: availability, description: description, date: date, albumTitle: "Без подборки")
                            products.append(product)
                        }
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


    
    
    func createExcelFile() -> String? {
        // Создаем имя файла для Excel
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let currentDateTime = dateFormatter.string(from: Date())
        let fileName = "\(VkIdData.currentGroupName!)_\(currentDateTime).xlsx"
        
        // Получаем путь к директории Documents в контейнере приложения
        guard let groupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.FS.myVkProductManagerApp") else {
            print("Failed to get container URL.")
            return nil
        }

        // Получаем путь к директории Documents в sandbox вашего приложения
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory.")
            return nil
        }
        // Создаем полный путь к файлу Excel
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Создаем новую книгу Excel
        guard let workbook = workbook_new(fileURL.path) else {
            print("Failed to create Excel workbook.")
            return nil
        }
        
        // Добавляем новый лист в книгу
        let worksheet = workbook_add_worksheet(workbook, "Товары")
        
        // Создаем формат для заголовков
        let boldFormat = workbook_add_format(workbook)
        format_set_bold(boldFormat)
        
        // Записываем заголовки в первую строку
        worksheet_write_string(worksheet, 0, 0, "ID", boldFormat)
        worksheet_write_string(worksheet, 0, 1, "Название", boldFormat)
        worksheet_write_string(worksheet, 0, 2, "Цена", boldFormat)
        worksheet_write_string(worksheet, 0, 3, "Валюта", boldFormat)
        worksheet_write_string(worksheet, 0, 4, "URL картинки", boldFormat)
        worksheet_write_string(worksheet, 0, 5, "Доступность", boldFormat)
        worksheet_write_string(worksheet, 0, 6, "Описание", boldFormat)
        worksheet_write_string(worksheet, 0, 7, "Дата создания", boldFormat)
        worksheet_write_string(worksheet, 0, 8, "Подборка", boldFormat)
        
        // Записываем данные о продуктах в соответствующие ячейки
        for (index, product) in products.enumerated() {
            let row: lxw_row_t = lxw_row_t(index + 1)
            let id = String(product.id)
            
            worksheet_write_string(worksheet, row, 0, id, nil)
            worksheet_write_string(worksheet, row, 1, product.title, nil)
            worksheet_write_string(worksheet, row, 2, product.price, nil)
            worksheet_write_string(worksheet, row, 3, product.currency, nil)
            worksheet_write_url(worksheet, row, 4, product.imageUrl.absoluteString, nil)
            let availabilityString: String
            switch product.availability {
            case 0:
                availabilityString = "доступен"
            case 1:
                availabilityString = "удален"
            case 2:
                availabilityString = "недоступен"
            default:
                availabilityString = "неизвестно"
            }
            worksheet_write_string(worksheet, row, 5, availabilityString, nil)
            worksheet_write_string(worksheet, row, 6, product.description, nil)
            worksheet_write_string(worksheet, row, 7, "\(product.date)", nil)
            worksheet_write_string(worksheet, row, 8, product.albumTitle, nil)
        }
        
        // Закрываем книгу
        workbook_close(workbook)
        
        //
        let pathToFile = "Таблица \(fileName) сохранена в папку Менеджер товаров ВК. Ее можно найти в приложении Файлы, в разделе iPhone."

        
        // Возвращаем URL созданного файла Excel
        return pathToFile
    }
    
    
    
}

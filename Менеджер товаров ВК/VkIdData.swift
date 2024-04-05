//
//  VkIdData.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 19.03.2024.
//

import Foundation
import VKID

struct VkIdData {
    
    let vkid: VKID
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    
    static var currentGroupName: String?
    static var currentGroupId: Int?
    static var currentGroupImage: UIImage?
    static let clientId = ""
    static let clientSecret = ""
    static var avatarImage: UIImage?
    static var currentProductId: Int?
    static var currentAlbumForProduct: String?


    
    func apiRequest(method: String, params: String, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: "https://api.vk.com/method/\(method)?\(params)&access_token=\( vkid.currentAuthorizedSession!.accessToken.value)&v=5.131") else {
            //Если URL недействителен, вызываем completion с ошибкой
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //Проверяем наличие ошибки
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем наличие данных и статуса ответа
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            //Проверяем наличие данных
            guard let responseData = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            //Парсим данные в формат JSON
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                completion(.success(json))
            } else {
                completion(.failure(NSError(domain: "Failed to parse JSON", code: 0, userInfo: nil)))
            }
        }
        //Запускаем запрос
        task.resume()
    }
        
}


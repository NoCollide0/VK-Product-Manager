//
//  GroupSelectorViewModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 21.03.2024.
//

import Foundation
import VKID

class GroupSelectorViewModel {

    var groups: [Group] = []
    let vkid: VKID
    var vkIdData = VkIdData(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    
    //Запрос и обработка данных получения списка групп
    func fetchGroups(completion: @escaping () -> Void) {
        vkIdData.apiRequest(method: "groups.get", params: "user_id=\(self.vkIdData.vkid.currentAuthorizedSession!.accessToken.userId.value)&filter=admin&filter=editor&extended=1") { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {
                    // Разбор данных и создание массива групп
                    var groups = [Group]()
                    for item in items {
                        if let id = item["id"] as? Int,
                           let name = item["name"] as? String,
                           let photoURLString = item["photo_100"] as? String,
                           let photoURL = URL(string: photoURLString) {
                            let group = Group(id: id, name: name, groupImageURL: photoURL)
                            groups.append(group)
                        }
                    }
                    self.groups = groups
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

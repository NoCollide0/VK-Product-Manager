//
//  LoginScreenViewModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 19.03.2024.
//

import Foundation
import VKID

class LoginScreenViewModel {

    let vkid: VKID
        
    init(vkid: VKID) {
        self.vkid = vkid
    }
    
    func authorize(presentingController: UIViewController, completion: @escaping (Result<UserSession, AuthError>) -> Void) {
        vkid.authorize(using: .uiViewController(presentingController)) { result in
            completion(result)
        }
    }
    
    
}

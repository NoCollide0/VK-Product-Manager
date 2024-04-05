//
//  ViewController.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 17.03.2024.
//

import UIKit
import VKID

class LoadingScreenViewController: UIViewController {
    
    @IBOutlet weak var vkLoginButtonView: UIView!
    
    @IBOutlet weak var vkLoginButton: UIButton!
    
    var loginScreenViewModel = LoginScreenViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func viewSetup() {
        vkLoginButtonView.layer.cornerRadius = vkLoginButtonView.bounds.height/2
    }

    
    @IBAction func vkLoginButtonTapped(_ sender: Any) {
        //Метод логина от VKID
        loginScreenViewModel.authorize(presentingController: self) { result in
            switch result {
            case .success(let session):
                print("Auth succeeded with token: \(session.accessToken) and user info: \(session.user)")
                
                //Переход на экран выбора группы
                if let groupSelectorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupSelectorViewController") as? GroupSelectorViewController {
                    groupSelectorViewController.modalPresentationStyle = .fullScreen
                    groupSelectorViewController.modalTransitionStyle = .crossDissolve
                    //Производим переход на экран выбора группы
                    self.present(groupSelectorViewController, animated: true, completion: nil)
                }
            case .failure(let error):
                print("Auth failed with error: \(error)")
                //Обработка ошибок авторизации
            }
        }
    }
    
    
}


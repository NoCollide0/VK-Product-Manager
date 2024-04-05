//
//  ExelScreenView.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 04.04.2024.
//

import UIKit
import VKID
import Lottie

class ExelScreenViewController: UIViewController {
    
    var exelScreenViewModel = ExelScreenViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    @IBOutlet weak var doneView: UIView!
    
    @IBOutlet weak var pathLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exelScreenViewModel.albums = []
        exelScreenViewModel.products = []
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
        buttonView.layer.cornerRadius = buttonView.bounds.height/2
        
        //Запускаем запрос на получение подборок
        exelScreenViewModel.fetchAlbums { [weak self] in
            var fetchProductsCount = 0
            //Если подборок 0
            if self?.exelScreenViewModel.albums.count == 0 {
                self?.exelScreenViewModel.fetchAllProducts {
                    DispatchQueue.main.async {
                        //После получения всех продуктов создаем файл Excel и обновляем интерфейс
                        if let pathToFile = self?.exelScreenViewModel.createExcelFile() {
                            self?.pathLabel.text = pathToFile
                            self?.exelDone()
                        }
                    }
                }
            } else {
                //После получения подборок запускаем запрос на получение товаров для каждого альбома
                for album in self?.exelScreenViewModel.albums ?? [] {
                    self?.exelScreenViewModel.fetchProducts(albumId: "&album_id=\(album.id)", albumTitle: album.title) {
                        fetchProductsCount += 1
                        if fetchProductsCount == self?.exelScreenViewModel.albums.count {
                            //Получаем товары без подборки
                            self?.exelScreenViewModel.fetchAllProducts {
                                DispatchQueue.main.async {
                                    //После получения всех продуктов создаем файл Excel и обновляем интерфейс
                                    if let pathToFile = self?.exelScreenViewModel.createExcelFile() {
                                        self?.pathLabel.text = pathToFile
                                        self?.exelDone()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func exelDone() {
        lottieAnimation.stop()
        statusLabel.isHidden = true
        lottieAnimation.isHidden = true
        doneView.isHidden = false
    }
    
    
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let mainScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreenViewController") as? MainScreenViewController {
            mainScreenViewController.modalPresentationStyle = .fullScreen
            mainScreenViewController.modalTransitionStyle = .crossDissolve
            self.present(mainScreenViewController, animated: true, completion: nil)
        }
    }
    
    
    
    
}

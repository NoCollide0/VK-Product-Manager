//
//  ProductScreenView.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 02.04.2024.
//

import UIKit
import VKID
import Lottie

class ProductScreenViewController: UIViewController {
    
    var productScreenViewModel = ProductScreenViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var avView: UIView!
    
    @IBOutlet weak var avSmallView: UIView!
    
    @IBOutlet weak var avLabel: UILabel!
    
    @IBOutlet weak var albumLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        
    }
    
    
    
    
    func viewSetup() {
        productImageView.isHidden = true
        lottieAnimation.isHidden = false
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
        avView.layer.cornerRadius = avView.bounds.height/2
        avSmallView.layer.cornerRadius = avSmallView.bounds.height/2
        productScreenViewModel.fetchProduct { productById in
            DispatchQueue.main.async {
                self.nameLabel.text = productById!.title
                self.albumLabel.text = VkIdData.currentAlbumForProduct
                self.priceLabel.text = "\(productById!.price) \(productById!.currency)"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let formattedDate = dateFormatter.string(from: productById!.date)
                self.dateLabel.text = formattedDate
                self.descriptionLabel.text = productById!.description
                
                self.productScreenViewModel.loadImage(from: productById!.imageUrl) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.productImageView?.image = image
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self?.lottieAnimation.stop()
                            self?.lottieAnimation.isHidden = true
                            self?.productImageView.isHidden = false
                        }
                    }
                }
                
                switch productById!.availability {
                case 0:
                    self.avLabel.text = "доступен"
                    self.avSmallView.backgroundColor = UIColor.green
                case 1:
                    self.avLabel.text = "удален"
                    self.avSmallView.backgroundColor = UIColor.red
                case 2:
                    self.avLabel.text = "недоступен"
                    self.avSmallView.backgroundColor = UIColor.gray
                default:
                    self.avLabel.text = "ERROR"
                    self.avSmallView.backgroundColor = UIColor.clear
                }
            }
            
        }
        
    }
    
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let mainScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreenViewController") as? MainScreenViewController {
            mainScreenViewController.modalPresentationStyle = .fullScreen
            mainScreenViewController.modalTransitionStyle = .crossDissolve
            self.present(mainScreenViewController, animated: true, completion: nil)
        }
    }
    
}

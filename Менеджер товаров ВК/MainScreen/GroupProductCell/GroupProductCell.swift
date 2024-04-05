//
//  GroupProductCell.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 28.03.2024.
//

import UIKit
import Lottie

class GroupProductCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var statusLightView: UIView!
    
    @IBOutlet weak var statusLightLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    var mainScreenViewModel = MainScreenViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    
    
    
    func setupView() {
        mainView.layer.cornerRadius = 6
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 3)
        mainView.layer.shadowOpacity = 0.25
        mainView.layer.shadowRadius = 10
        
        statusView.layer.cornerRadius = statusView.bounds.height/2
        
        statusLightView.layer.cornerRadius = statusLightView.bounds.height/2
        

    }
    
    
    func configure(with product: Product) {
        lottieAnimation.isHidden = false
        imageView.isHidden = true
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
        productNameLabel.text = product.title
        productPriceLabel.text = "\(product.price) \(product.currency)"
        
        mainScreenViewModel.loadImage(from: product.imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView?.image = image
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self?.lottieAnimation.stop()
                    self?.lottieAnimation.isHidden = true
                    self?.imageView.isHidden = false
                }
            }
        }
        
        switch product.availability {
        case 0:
            statusLightLabel.text = "доступен"
            statusLightView.backgroundColor = UIColor.green
        case 1:
            statusLightLabel.text = "удален"
            statusLightView.backgroundColor = UIColor.red
        case 2:
            statusLightLabel.text = "недоступен"
            statusLightView.backgroundColor = UIColor.gray
        default:
            statusLightLabel.text = "ERROR"
            statusLightView.backgroundColor = UIColor.clear
        }
    }
    
    
    
    
}

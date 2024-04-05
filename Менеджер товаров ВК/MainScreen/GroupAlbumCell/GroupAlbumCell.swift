//
//  GroupAlbumCell.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 28.03.2024.
//

import UIKit

class GroupAlbumCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var albumName: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        // Initialization code
    }
    
    
    
    
    func setupView() {
        //Настройка большого view
        mainView.layer.cornerRadius = 6
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 3)
        mainView.layer.shadowOpacity = 0.25
        mainView.layer.shadowRadius = 10
        
        //Настройка малого view
        subView.layer.cornerRadius = 6
        subView.layer.borderWidth = 2
        subView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let borderGradientLayer = CAGradientLayer()
        borderGradientLayer.frame = subView.bounds
        borderGradientLayer.colors = [UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 215/255, green: 208/255, blue: 208/255, alpha: 1.0).cgColor]
        borderGradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        borderGradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        borderGradientLayer.cornerRadius = 6
        let borderImage = UIGraphicsImageRenderer(size: subView.bounds.size).image { _ in
            borderGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        }
        subView.layer.borderColor = UIColor(patternImage: borderImage).cgColor
        
    }
    
    
    func configure(with album: Album) {
        albumName.text = album.title
    }
    
    
    
}

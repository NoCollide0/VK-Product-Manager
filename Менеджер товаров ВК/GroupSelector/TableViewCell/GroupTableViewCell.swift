//
//  GroupTableViewCell.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 22.03.2024.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var groupSelectorViewModel = GroupSelectorViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.layer.borderWidth = 1
        groupImageView.layer.borderColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1).cgColor
        nameView.layer.borderWidth = 1
        nameView.layer.borderColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1).cgColor
        groupImageView.layer.cornerRadius = groupImageView.bounds.height/2
        nameView.layer.cornerRadius = nameView.bounds.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(with group: Group) {
        nameLabel?.text = group.name
        groupSelectorViewModel.loadImage(from: group.groupImageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.groupImageView?.image = image
            }
        }
    }
    
}

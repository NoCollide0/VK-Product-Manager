//
//  TableViewGroupCell.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 22.03.2024.
//

import UIKit

class TableViewGroupCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var groupSelectorViewModel = GroupSelectorViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.layer.cornerRadius = groupImageView.bounds.height/2
        nameView.layer.cornerRadius = nameView.bounds.height/2
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

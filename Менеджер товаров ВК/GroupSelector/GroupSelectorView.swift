//
//  GroupSelectorView.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 21.03.2024.
//

import UIKit
import VKID
import Lottie

class GroupSelectorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var groupListTableView: UITableView!
    
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    @IBOutlet weak var avatarLottieAnimation: LottieAnimationView!
    
    var groupSelectorViewModel = GroupSelectorViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupListTableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "groupCell")
        groupListTableView.dataSource = self
        groupListTableView.delegate = self
        viewSetup()

        
    }
    
    func viewSetup() {
        groupListTableView.isHidden = true
        userAvatarImageView.isHidden = true
        lottieAnimation.loopMode = .loop
        avatarLottieAnimation.loopMode = .loop
        lottieAnimation.play()
        avatarLottieAnimation.play()
        
        //Установка фото пользователя
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.bounds.height/2
        groupSelectorViewModel.loadImage(from: (groupSelectorViewModel.vkid.currentAuthorizedSession?.user.avatarURL)!) { [weak self] image in
            DispatchQueue.main.async {
                self?.userAvatarImageView.image = image
                VkIdData.avatarImage = image
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self?.avatarLottieAnimation.stop()
                    self?.avatarLottieAnimation.isHidden = true
                    self?.userAvatarImageView.isHidden = false
                }
                
            }
        }
        //Установка имени пользователя
        userName.text = "\(groupSelectorViewModel.vkid.currentAuthorizedSession!.user.firstName)  \(groupSelectorViewModel.vkid.currentAuthorizedSession!.user.lastName)"
        
        //Апи запрос на получение групп
        groupSelectorViewModel.fetchGroups { [weak self] in
            DispatchQueue.main.async {
                self?.groupListTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self?.lottieAnimation.stop()
                    self?.lottieAnimation.isHidden = true
                    self?.groupListTableView.isHidden = false
                }
            }
        }

        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSelectorViewModel.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as? GroupTableViewCell else {
            fatalError("Unable to dequeue GroupTableViewCell")
        }
        
        //Получаем группу 
        let group = groupSelectorViewModel.groups[indexPath.row]
        
        //Настройка ячейки с данными группы
        cell.configure(with: group)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GroupTableViewCell else {
            return
        }
        
        VkIdData.currentGroupImage = cell.groupImageView.image
        VkIdData.currentGroupId = groupSelectorViewModel.groups[indexPath.row].id
        VkIdData.currentGroupName = groupSelectorViewModel.groups[indexPath.row].name
        
        //Переход на главный экран
        if let mainScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreenViewController") as? MainScreenViewController {
            mainScreenViewController.modalPresentationStyle = .fullScreen
            mainScreenViewController.modalTransitionStyle = .crossDissolve
            self.present(mainScreenViewController, animated: true, completion: nil)
        }
    }
    
}

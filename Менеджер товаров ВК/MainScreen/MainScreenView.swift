//
//  MainScreenView.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 26.03.2024.
//

import UIKit
import VKID
import Lottie

class MainScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var groupImageViewMain: UIView!
    
    @IBOutlet weak var groupNameView: UIView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var mainScreenCollectionView: UICollectionView!
    
    var mainScreenViewModel = MainScreenViewModel(vkid: (UIApplication.shared.delegate as! AppDelegate).vkid)
    
    var albumCheck = true
    
    @IBOutlet weak var backButtonView: UIView!
    
    @IBOutlet weak var noProductLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButtonImage: UIImageView!
    
    var isSearching = false
    
    var tapGesture: UITapGestureRecognizer?
    
    var currentAlbum = ""
    
    
    
    //Относится к боковому меню
    @IBOutlet weak var menuMainView: UIView!
    
    @IBOutlet weak var menuBodyView: UIView!
    
    @IBOutlet weak var menuExitButtonView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userAvatarView: UIView!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScreenViewModel.shouldLoadMore = true
        currentAlbum = ""
        mainScreenViewModel.offset = 0
        mainScreenViewModel.products = []
        mainScreenCollectionView.register(UINib(nibName: "GroupAlbumCell", bundle: nil), forCellWithReuseIdentifier: "albumCell")
        mainScreenCollectionView.register(UINib(nibName: "GroupProductCell", bundle: nil), forCellWithReuseIdentifier: "productCell")
        mainScreenCollectionView.dataSource = self
        mainScreenCollectionView.delegate = self
        searchTextField.delegate = self
        
        viewSetup()
        
        mainScreenViewModel.fetchAlbums { [weak self] in
            DispatchQueue.main.async {
                self?.mainScreenCollectionView.reloadData()
            }
        }
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        menuBodyView.frame.origin.x -= menuBodyView.frame.width
    }
    
    
    
    func viewSetup() {
        searchView.layer.cornerRadius = searchView.bounds.height/2
        searchView.layer.shadowColor = UIColor.black.cgColor
        searchView.layer.shadowOffset = CGSize(width: 0, height: 3)
        searchView.layer.shadowOpacity = 0.25
        searchView.layer.shadowRadius = 4
        
        backButtonView.layer.cornerRadius = backButtonView.bounds.height/2
        backButtonView.isHidden = true
        
        //Аватарка группы
        groupImageViewMain.layer.cornerRadius = groupImageViewMain.bounds.height/2
        groupImageView.layer.cornerRadius = groupImageView.bounds.height/2
        groupImageViewMain.layer.shadowColor = UIColor.black.cgColor
        groupImageViewMain.layer.shadowOffset = CGSize(width: 0, height: 3)
        groupImageViewMain.layer.shadowOpacity = 0.25
        groupImageViewMain.layer.shadowRadius = 4
        if let groupImageCheck = VkIdData.currentGroupImage {
            groupImageView.image = groupImageCheck
        } else {
            print("Аватар группы отсутсвует")
        }
        
        groupNameView.layer.cornerRadius = groupNameView.bounds.height/2
        groupNameView.layer.shadowColor = UIColor.black.cgColor
        groupNameView.layer.shadowOffset = CGSize(width: 0, height: 3)
        groupNameView.layer.shadowOpacity = 0.25
        groupNameView.layer.shadowRadius = 4
        groupNameLabel.text = VkIdData.currentGroupName!
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture!)
        tapGesture?.isEnabled = false
        
        //Относится к боковому меню
        userNameLabel.text = "\(mainScreenViewModel.vkid.currentAuthorizedSession!.user.firstName)  \(mainScreenViewModel.vkid.currentAuthorizedSession!.user.lastName)"
        
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.height/2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.bounds.height/2
        userAvatarView.layer.shadowColor = UIColor.black.cgColor
        userAvatarView.layer.shadowOffset = CGSize(width: 0, height: 3)
        userAvatarView.layer.shadowOpacity = 0.25
        userAvatarView.layer.shadowRadius = 4
        if let userImageCheck = VkIdData.avatarImage {
            userAvatarImageView.image = userImageCheck
        } else {
            print("Аватар пользователя отсутсвует")
        }
        
        menuMainView.isHidden = true
        menuExitButtonView.alpha = 0
        
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if albumCheck == true {
            return mainScreenViewModel.albums.count + 1
        } else {
            return mainScreenViewModel.products.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Если пользователь долистал до предпоследней строчки ячеек грузим еще, если есть что грузить
        if albumCheck == false && indexPath.row >= mainScreenViewModel.products.count - 2 && mainScreenViewModel.shouldLoadMore {
            mainScreenViewModel.fetchProducts(albumId: "\(currentAlbum)") { [weak self] in
                DispatchQueue.main.async {
                    self?.mainScreenCollectionView.reloadData()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 14
        let numberOfCellsInRow: CGFloat = 2
        let totalSpacing = (numberOfCellsInRow - 1) * spacingBetweenCells
        let cellWidth = (collectionViewWidth - totalSpacing) / numberOfCellsInRow
        
        if albumCheck == true {
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            let cellHeight = cellWidth * (240.0 / 200.0) // Сохраняем соотношение высоты к ширине
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if albumCheck == true {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as? GroupAlbumCell else {
                fatalError("Unable to dequeue GroupAlbumCell")
            }
            if indexPath.row == 0 {
                cell.albumName.text = "ВСЕ ТОВАРЫ"
                return cell
            } else {
                let album = mainScreenViewModel.albums[indexPath.row - 1]
                cell.configure(with: album)
                return cell
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as? GroupProductCell else {
                fatalError("Unable to dequeue GroupProductCell")
            }
            let product = mainScreenViewModel.products[indexPath.row]
            cell.configure(with: product)
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if albumCheck == true {
            albumCheck = false
            if indexPath.row == 0 {
                currentAlbum = ""
                mainScreenViewModel.fetchProducts(albumId: "") { [weak self] in
                    DispatchQueue.main.async {
                        self?.mainScreenCollectionView.reloadData()
                        self?.backButtonView.isHidden = false
                        if self?.mainScreenViewModel.products.count == 0 {
                            self?.noProductLabel.isHidden = false
                        }
                        VkIdData.currentAlbumForProduct = ""
                    }
                }
            } else {
                let selectedAlbum = mainScreenViewModel.albums[indexPath.row - 1]
                currentAlbum = "&album_id=\(selectedAlbum.id)"
                mainScreenViewModel.fetchProducts(albumId: "&album_id=\(selectedAlbum.id)") { [weak self] in
                    DispatchQueue.main.async {
                        self?.mainScreenCollectionView.reloadData()
                        self?.backButtonView.isHidden = false
                        if self?.mainScreenViewModel.products.count == 0 {
                            self?.noProductLabel.isHidden = false
                        }
                        VkIdData.currentAlbumForProduct = selectedAlbum.title
                    }
                }
            }
        } else {
            let selectedProduct = mainScreenViewModel.products[indexPath.row]
            VkIdData.currentProductId = selectedProduct.id
            if let productScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productScreenViewController") as? ProductScreenViewController {
                productScreenViewController.modalPresentationStyle = .fullScreen
                productScreenViewController.modalTransitionStyle = .crossDissolve
                self.present(productScreenViewController, animated: true, completion: nil)
            }
        }
                
    }
    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchButtonImage.image = UIImage(named: "searchCancel")
        tapGesture?.isEnabled = true
     }

     func textFieldDidEndEditing(_ textField: UITextField) {
         tapGesture?.isEnabled = false
         if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
             searchButtonImage.image = UIImage(named: "searchLupa")
             textField.text = ""
         }
         
     }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            searchButtonImage.image = UIImage(named: "searchLupa")
            textField.text = ""
        } else {
            mainScreenViewModel.shouldLoadMore = false
            currentAlbum = ""
            mainScreenViewModel.offset = 0
            mainScreenViewModel.products = []
            mainScreenViewModel.search(q: (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) { [weak self] in
                DispatchQueue.main.async {
                    self?.noProductLabel.isHidden = true
                    self?.albumCheck = false
                    self?.isSearching = true
                    self?.backButtonView.isHidden = false
                    self?.mainScreenCollectionView.reloadData()
                    if self?.mainScreenViewModel.products.count == 0 {
                        self?.noProductLabel.isHidden = false
                    }
                }
            }
        }
        //Возвращаем true для выполнения стандартного поведения по нажатию Return
        return true
    }
    
    //Метод для скрытия клавиатуры при касании вне текстового поля
     @objc func dismissKeyboard() {
         view.endEditing(true)
     }
    
    
    
    
    //Кнопка назад
    @IBAction func backButtonTapped(_ sender: Any) {
        albumCheck = true
        noProductLabel.isHidden = true
        mainScreenViewModel.shouldLoadMore = true
        currentAlbum = ""
        mainScreenViewModel.offset = 0
        mainScreenViewModel.products = []
        mainScreenViewModel.fetchAlbums { [weak self] in
            DispatchQueue.main.async {
                self?.mainScreenCollectionView.reloadData()
                self?.backButtonView.isHidden = true
            }
        }
        if isSearching == true {
            isSearching = false
            searchTextField.text = ""
            dismissKeyboard()
            searchButtonImage.image = UIImage(named: "searchLupa")
        }
        
    }
    
    //Кнопка поиска. Лупа/крестик
    @IBAction func searchButtonTapped(_ sender: Any) {
        if searchButtonImage.image == UIImage(named: "searchLupa"){
            searchTextField.becomeFirstResponder()
        } else {
            if isSearching == true {
                albumCheck = true
                mainScreenViewModel.shouldLoadMore = true
                currentAlbum = ""
                mainScreenViewModel.products = []
                mainScreenViewModel.offset = 0
                noProductLabel.isHidden = true
                isSearching = false
                searchTextField.text = ""
                dismissKeyboard()
                searchButtonImage.image = UIImage(named: "searchLupa")
                mainScreenViewModel.fetchAlbums { [weak self] in
                    DispatchQueue.main.async {
                        self?.mainScreenCollectionView.reloadData()
                        self?.backButtonView.isHidden = true
                    }
                }
            } else {
                searchTextField.text = ""
                dismissKeyboard()
                searchButtonImage.image = UIImage(named: "searchLupa")
            }
        }
    }
    
    
    //Кнопка вызова бокового меню
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuMainView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.menuBodyView.frame.origin.x += self.menuBodyView.frame.width
            self.menuExitButtonView.alpha = 1
        }
        
    }
    
    
    //Кнопка закрытия бокового меню
    @IBAction func menuExitButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.menuBodyView.frame.origin.x -= self.menuBodyView.frame.width
            self.menuExitButtonView.alpha = 0
        }, completion: { _ in
            self.menuMainView.isHidden = true
        })
    }
    
    
    //КНОПКА МЕНЮ: кнопка смены группы
    @IBAction func changeGroupButtonTapped(_ sender: Any) {
        if let groupSelectorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupSelectorViewController") as? GroupSelectorViewController {
            groupSelectorViewController.modalPresentationStyle = .fullScreen
            groupSelectorViewController.modalTransitionStyle = .crossDissolve
            self.present(groupSelectorViewController, animated: true, completion: nil)
        }
    }
    
    
    //КНОПКА МЕНЮ: кнопка создания таблицы
    @IBAction func exelButtonTapped(_ sender: Any) {
        if let exelScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "exelScreenViewController") as? ExelScreenViewController {
            exelScreenViewController.modalPresentationStyle = .fullScreen
            exelScreenViewController.modalTransitionStyle = .crossDissolve
            self.present(exelScreenViewController, animated: true, completion: nil)
        }
    }
    
    
    //КНОПКА МЕНЮ: кнопка выхода из аккаунта
    @IBAction func exitButtonTapped(_ sender: Any) {
        mainScreenViewModel.vkid.currentAuthorizedSession?.logout {_ in
            if let loadingScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loadingScreenViewController") as? LoadingScreenViewController {
                loadingScreenViewController.modalPresentationStyle = .fullScreen
                loadingScreenViewController.modalTransitionStyle = .crossDissolve
                self.present(loadingScreenViewController, animated: true, completion: nil)
            }
        }
    }
    
    
}

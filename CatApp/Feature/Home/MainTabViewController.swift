//
//  MainTabViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation
import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    private lazy var homeVC: UIViewController = {
        let vc = HomeViewController(viewModel: HomeViewModel())
        vc.tabBarItem = UITabBarItem(title: "",
                                     image: UIImage(systemName: "house"),
                                     selectedImage: UIImage(systemName: "house.fill"))
        return UINavigationController(rootViewController: vc)
    }()
    
    private lazy var favoriteVC: UIViewController = {
        let vc = FavoriteViewController()
        vc.tabBarItem = UITabBarItem(title: "",
                                     image: UIImage(systemName: "heart"),
                                     selectedImage: UIImage(systemName: "heart.fill"))
        return UINavigationController(rootViewController: vc)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTabs() {
        view.backgroundColor = .white
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        
        viewControllers = [homeVC, favoriteVC]
    }
}

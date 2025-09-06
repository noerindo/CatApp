//
//  ViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        moveToHome()
    }
    
    private func moveToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate else { return }
            
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            let moveVC = isLoggedIn ? MainTabViewController() : LoginViewController()
            let nav = UINavigationController(rootViewController: moveVC)
            
            delegate.window?.rootViewController = nav
            delegate.window?.makeKeyAndVisible()
        }
    }
    
}



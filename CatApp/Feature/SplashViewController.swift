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
        
        LocalizationManager.shared.configure(defaultLanguage: "id")
        moveToNextScreen(after: 0.5)
    }
    
    private func moveToNextScreen(after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self,
                  let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            let nextVC: UIViewController = isLoggedIn ? MainTabViewController() : LoginViewController()
            let nav = UINavigationController(rootViewController: nextVC)
            
            window.rootViewController = nav
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}




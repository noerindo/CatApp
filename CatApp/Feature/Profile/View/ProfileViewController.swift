//
//  ProfileViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift
import Action

class ProfileViewController: UIViewController {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var languageSwitch: UISwitch!
    @IBOutlet weak var laguageLabel: UILabel!
    @IBOutlet weak var bgLanguangeView: UIView!
    
    private let viewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        setupUI()
    }
    
    private func binding() {
        viewModel.name
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.fetchUser()
    }
    
    private func setupUI() {
        languageSwitch.isOn = LocalizationManager.shared.currentLang == "en"
        setupTexts()
    }
    
    private func setupTexts() {
        LocalizationManager.shared.toggleLanguage()
        greetingLabel.text = LocalizationManager.shared.t("greeting_")
        descLabel.text = LocalizationManager.shared.t("description_")
        logoutButton.setTitle(LocalizationManager.shared.t("logout_"), for: .normal)
        changeColorButton.setTitle(LocalizationManager.shared.t("changeColor_"), for: .normal)
        laguageLabel.text = LocalizationManager.shared.t("language_")
    }
    
    @IBAction func languageSwitchChanged(_ sender: UISwitch) {
        LocalizationManager.shared.setLanguage(sender.isOn ? "en" : "id")
        LocalizationManager.shared.loadJson(language: LocalizationManager.shared.currentLang)
        setupTexts()
    }
    
    @IBAction func changeColorTapped(_ sender: UIButton) {
        let color = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
        
        UIView.animate(withDuration: 0.5) {
            self.bgLanguangeView.backgroundColor = color
        }
    }
    @IBAction func goLogout(_ sender: Button) {
        viewModel.logout()
        moveToLogin()
    }
    
    func moveToLogin(after delay: TimeInterval = 1.0) {
        let workItem = DispatchWorkItem {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nav
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
}

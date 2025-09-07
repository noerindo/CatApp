//
//  ProfileViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift
import Action
import BCColor

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
    @IBOutlet weak var photoImageView: UIImageView!
    
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
        let colors = getRandomBCColor(for: photoImageView)
        
        UIView.animate(withDuration: 0.5) {
            self.bgLanguangeView.backgroundColor = colors.bgColor
            self.photoImageView.backgroundColor = colors.imageColor
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

extension ProfileViewController {
    
    func getRandomBCColor(for imageView: UIImageView?) -> (bgColor: UIColor, imageColor: UIColor) {
        let randomMode = Int.random(in: 0...3)
        var bgColor: UIColor
        var imageColor: UIColor
        
        switch randomMode {
        case 0:
            let hexColors = ["#3498db", "#e74c3c", "#2ecc71", "#f1c40f"]
            bgColor = UIColor.colorWithHex(hexColors.randomElement()!)!
            imageColor = bgColor
        case 1:
            let gradientColors = [UIColor.colorWithHex("#3498db")!, UIColor.colorWithHex("#e74c3c")!]
            bgColor = UIColor.gradientColor(CGPoint(x: 0, y: 0),
                                            endPoint: CGPoint(x: 1, y: 1),
                                            frame: bgLanguangeView.bounds,
                                            colors: gradientColors)!
            imageColor = bgColor
        case 2:
            let baseColor = UIColor.colorWithHex("#2ecc71")!
            bgColor = Bool.random() ? baseColor.lightenByPercentage(0.2) : baseColor.darkenByPercentage(0.2)
            imageColor = bgColor
        case 3:
            if let image = imageView?.image {
                let colors = image.getColors()
                bgColor = colors.primaryColor
                imageColor = colors.secondaryColor
            } else {
                bgColor = UIColor.colorWithHex("#3498db")!
                imageColor = bgColor
            }
        default:
            bgColor = UIColor.colorWithHex("#3498db")!
            imageColor = bgColor
        }
        
        return (bgColor, imageColor)
    }
    
}

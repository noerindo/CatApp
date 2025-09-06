//
//  LoginViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regisLabel: UILabel!
    @IBOutlet weak var regisButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    private let viewModel: LoginViewModelProtocol
    private let disposeBag = DisposeBag()
    
    
    init(viewModel: LoginViewModelProtocol = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LoginViewModel()
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    func setupView() {
        loadingView.isHidden = true
        passTextField.isSecureTextEntry = true
        passTextField.enablePasswordToggle()
        regisButton.addTarget(self, action: #selector(goToRegister), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.loadingView.start()
                self?.viewModel.loginTapped.accept(())
            })
            .disposed(by: disposeBag)
        
        viewModel.successMessage
            .subscribe(onNext: { [weak self] message in
                self?.loadingView.stop()
                SnackBarWarning.make(in: self!.view, message: message, duration: .lengthShort).show()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                self?.loadingView.stop()
                SnackBarWarning.make(in: self!.view, message: message, duration: .lengthShort).show()
            })
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadingView.stop()
                    self.navigateToHome()
                    
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func goToRegister() {
        let registerVC = RegisterViewController(viewModel: RegisterViewModel())
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func navigateToHome() {
        let tabVC = MainTabViewController()
        let nav = UINavigationController(rootViewController: tabVC)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
}

//
//  RegisterViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift

class RegisterViewController: UIViewController {
    
    private let viewModel: RegisterViewModelProtocol
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var regisButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    init(viewModel: RegisterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    private func bindViewModel() {
        
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        regisButton.rx.tap
            .bind(to: viewModel.registerTapped)
            .disposed(by: disposeBag)
        
        viewModel.successMessage
            .subscribe(onNext: { [weak self] msg in
                guard let self = self, let view = self.view else { return }
                
                SnackBarSuccess.make(in: view, message: msg, duration: .lengthShort).show()
                
                loadingView.start()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadingView.stop()
                    self.navigateToLogin()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] msg in
                guard let view = self?.view else { return }
                SnackBarWarning.make(in: view, message: msg, duration: .lengthShort).show()
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
}

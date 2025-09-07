//
//  Extension.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//
import UIKit

extension UITextField {
    
    func enablePasswordToggle() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        self.rightView = button
        self.rightViewMode = .always
        self.isSecureTextEntry = true
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        
        let imageName = self.isSecureTextEntry ? "eye" : "eye.slash.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        
        let currentText = self.text
        self.text = nil
        self.text = currentText
        
        self.becomeFirstResponder()
    }
}

extension UIActivityIndicatorView {
    
    func start() {
        self.isHidden = false
        self.startAnimating()
    }
    
    func stop() {
        self.stopAnimating()
        self.hidesWhenStopped = true
        self.isHidden = true
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

//
//  LocalizationManager.swift
//  CatApp
//
//  Created by Phincon on 07/09/25.
//

import Foundation
import i18next

final class LocalizationManager {
    
    static let shared = LocalizationManager()
    private let i18n = I18Next.sharedInstance()
    private(set) var currentLang: String = "en"
    
    private init() {}
    
    func configure(defaultLanguage: String = "en") {
        currentLang = defaultLanguage
        
        loadJson(language: "id")
        loadJson(language: "en")
        
        i18n?.lang = defaultLanguage
    }
    
    func loadJson(language: String) {
        guard let url = Bundle.main.url(forResource: language, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        let options: [String: Any] = [
            "resourcesStore": [
                language: [
                    "translation": json
                ]
            ],
            "lang": language
        ]
        
        i18n?.load(options: options) { error in
            if let e = error {
                print("❌ Failed to load resource for \(language): \(e)")
            }
        }
    }
    
    func setLanguage(_ language: String) {
        currentLang = language
        i18n?.lang = language
        loadJson(language: language)
    }
    
    func toggleLanguage() {
        currentLang = (currentLang == "en") ? "en" : "id"
        i18n?.lang = currentLang
        loadJson(language: currentLang)
        
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    func t(_ key: String) -> String {
        return i18n?.t(key) ?? key
    }
}

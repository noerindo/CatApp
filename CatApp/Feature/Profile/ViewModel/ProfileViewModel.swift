//
//  ProfileViewModel.swift
//  CatApp
//
//  Created by Phincon on 07/09/25.
//

import RxSwift
import RxCocoa
import RealmSwift

class ProfileViewModel {
    
    let name = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    func fetchUser() {
        guard let userIdString = UserDefaults.standard.string(forKey: "loggedInUserId"),
              let userId = try? ObjectId(string: userIdString) else {
            return
        }
        
        do {
            let realm = try Realm()
            if let user = realm.object(ofType: UserModel.self, forPrimaryKey: userId) {
                name.accept(user.name)
            }
        } catch {
            print("Terjadi kesalahan Realm: \(error.localizedDescription)")
        }
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
    }
}


//
//  Service.swift
//  CatApp
//
//  Created by Phincon on 06/09/25.
//

import RealmSwift

class UserRepository {
    private let realm = try! Realm()
    
    func addFavoriteCat(userId: ObjectId, cat: FavoriteCatModel) {
        guard let user = realm.object(ofType: UserModel.self, forPrimaryKey: userId) else { return }
        try! realm.write {
            if !user.favoriteCats.contains(where: { $0.id == cat.id }) {
                user.favoriteCats.append(cat)
            }
        }
    }
    
    func removeFavoriteCat(userId: ObjectId, catId: String) {
        guard let user = realm.object(ofType: UserModel.self, forPrimaryKey: userId) else { return }
        if let index = user.favoriteCats.firstIndex(where: { $0.id == catId }) {
            try! realm.write {
                user.favoriteCats.remove(at: index)
            }
        }
    }
    
    func getFavoriteCats(userId: ObjectId) -> [FavoriteCatModel] {
        guard let user = realm.object(ofType: UserModel.self, forPrimaryKey: userId) else { return [] }
        return Array(user.favoriteCats)
    }
}


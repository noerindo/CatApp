//
//  UserModel.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation
import RealmSwift

class UserModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var email: String = ""
    @Persisted var password: String = ""
    @Persisted var name: String = ""
    @Persisted var favoriteCats = List<FavoriteCatModel>()
}

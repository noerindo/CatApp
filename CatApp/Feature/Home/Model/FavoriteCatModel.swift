//
//  FavoriteCatModel.swift
//  CatApp
//
//  Created by Phincon on 06/09/25.
//

import RealmSwift

class FavoriteCatModel: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String = ""
    @Persisted var imageUrl: String = ""
    @Persisted var temperamentCat: String = ""
    @Persisted var descriptionCat: String = ""
}

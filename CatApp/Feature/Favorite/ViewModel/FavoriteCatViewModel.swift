//
//  FavoriteCatViewModel.swift
//  CatApp
//
//  Created by Phincon on 06/09/25.
//

import RealmSwift
import RxSwift
import RxCocoa

class FavoriteCatViewModel {
    private let realm = try! Realm()
    
    private var currentUser: UserModel? {
        guard let objectIdString = UserDefaults.standard.string(forKey: "loggedInUserId"),
              let objectId = try? ObjectId(string: objectIdString) else { return nil }
        let realm = try! Realm()
        return realm.object(ofType: UserModel.self, forPrimaryKey: objectId)
    }
    
    var favoriteCats = BehaviorRelay<[FavoriteCatModel]>(value: [])
    var toggleStatus = PublishRelay<(catId: String, isFavorite: Bool)>()
    
    private var notificationToken: NotificationToken?
    
    init() {
        loadFavorites()
        observeFavorites()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func loadFavorites() {
        guard let user = currentUser else { return }
        favoriteCats.accept(Array(user.favoriteCats))
    }
    
    private func observeFavorites() {
        guard let user = currentUser else { return }
        notificationToken = user.favoriteCats.observe { [weak self] changes in
            switch changes {
            case .initial(let cats):
                self?.favoriteCats.accept(Array(cats))
            case .update(let cats, _, _, _):
                self?.favoriteCats.accept(Array(cats))
            case .error(let error):
                print("Realm error: \(error)")
            }
        }
    }
    
    func toggleFavorite(cat: FavoriteCatModel) {
        guard let user = currentUser else { return }
        var isNowFavorite = false
        
        if let index = user.favoriteCats.firstIndex(where: { $0.imageUrl == cat.imageUrl }) {
            try! realm.write {
                user.favoriteCats.remove(at: index)
                isNowFavorite = false
            }
        } else {
            try! realm.write {
                user.favoriteCats.append(cat)
                isNowFavorite = true
            }
        }
        loadFavorites()
        toggleStatus.accept((catId: cat.id, isFavorite: isNowFavorite))
    }
    
    func isFavorite(imageUrlCat: String) -> Bool {
        guard let user = currentUser else { return false }
        return user.favoriteCats.contains(where: { $0.imageUrl == imageUrlCat })
    }
}

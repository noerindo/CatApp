//
//  FavoriteDetailViewController.swift
//  CatApp
//
//  Created by Phincon on 07/09/25.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift

class FavoriteDetailViewController: UIViewController {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempramentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoCatImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var cat: FavoriteCatModel?
    var favoriteViewModel: FavoriteCatViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    private func bindData() {
        guard let cat = cat else { return }
        nameLabel.text = cat.name
        descLabel.text = cat.descriptionCat
        tempramentLabel.text = cat.temperamentCat
        if let url = URL(string: cat.imageUrl) {
            photoCatImageView.kf.setImage(with: url)
        }
        
        updateFavoriteUI()
        
        favoriteViewModel?.toggleStatus
            .subscribe(onNext: { [weak self] status in
                guard let self = self, let cat = self.cat else { return }
                if status.catId == cat.id {
                    let imageName = status.isFavorite ? "heart.fill" : "heart"
                    self.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateFavoriteUI() {
        guard let cat = cat else { return }
        let isFav = favoriteViewModel?.isFavorite(imageUrlCat: cat.imageUrl) ?? false
        let imageName = isFav ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let cat = cat else { return }
        favoriteViewModel?.toggleFavorite(cat: cat)
    }
}

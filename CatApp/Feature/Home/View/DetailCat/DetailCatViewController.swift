//
//  DetailCatViewController.swift
//  CatApp
//
//  Created by Phincon on 06/09/25.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class DetailCatViewController: UIViewController {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempramentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoCatImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel: CatDetailViewModelProtocol
    var favoriteViewModel: FavoriteCatViewModel?
    
    private let disposeBag = DisposeBag()
    private var currentCat: CatDetailModel?
    
    init(viewModel: CatDetailViewModelProtocol, favoriteViewModel: FavoriteCatViewModel) {
        self.viewModel = viewModel
        self.favoriteViewModel = favoriteViewModel
        super.init(nibName: "DetailCatViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        activityIndicator.hidesWhenStopped = true
        favoriteButton.layer.cornerRadius = 8
        favoriteButton.clipsToBounds = true
    }
    
    private func bindViewModel() {
        viewModel.isLoading
            .drive(onNext: { [weak self] loading in
                loading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        viewModel.catDetail
            .drive(onNext: { [weak self] cat in
                guard let self = self, let cat = cat else { return }
                self.currentCat = cat
                self.updateUIWithCat(cat)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUIWithCat(_ cat: CatDetailModel) {
        nameLabel.text = cat.name
        descLabel.text = cat.description
        tempramentLabel.text = cat.temperament
        if let url = URL(string: cat.imageUrl) {
            photoCatImageView.kf.setImage(with: url)
        }
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        guard let cat = currentCat else { return }
        let isFavorite = favoriteViewModel?.isFavorite(imageUrlCat: cat.imageUrl) ?? false
        let image = isFavorite
        ? UIImage(systemName: "heart.fill")!.withTintColor(.red, renderingMode: .alwaysOriginal)
        : UIImage(systemName: "heart")!
        favoriteButton.setImage(image, for: .normal)
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let cat = currentCat else { return }
        let model = FavoriteCatModel()
        model.id = cat.id
        model.name = cat.name
        model.imageUrl = cat.imageUrl
        model.temperamentCat = cat.temperament
        model.descriptionCat = cat.description
        
        favoriteViewModel?.toggleFavorite(cat: model)
        updateFavoriteButton()
    }
}

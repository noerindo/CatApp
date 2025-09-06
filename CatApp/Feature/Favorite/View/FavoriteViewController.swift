//
//  FavoriteViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let favoriteViewModel = FavoriteCatViewModel()
    private let disposeBag = DisposeBag()
    
    private var isGrid: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
        setupToggleButton()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CatCollectionViewCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func bindViewModel() {
        favoriteViewModel.favoriteCats
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupToggleButton() {
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }
    
    @objc private func toggleTapped() {
        isGrid.toggle()
        let icon = isGrid ? "square.grid.2x2" : "list.bullet"
        toggleButton.setImage(UIImage(systemName: icon), for: .normal)
        collectionView.reloadData()
    }
}

extension FavoriteViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteViewModel.favoriteCats.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CatCollectionViewCell",
            for: indexPath
        ) as? CatCollectionViewCell else { return UICollectionViewCell() }
        
        let cat = favoriteViewModel.favoriteCats.value[indexPath.row]
        cell.viewModel = CardCatViewModel(id: cat.id, imageUrl: cat.imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return isGrid ? CGSize(width: (width / 2) - 8, height: 110)
        : CGSize(width: width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cat = favoriteViewModel.favoriteCats.value[indexPath.row]
        let detailVC = FavoriteDetailViewController()
        detailVC.cat = cat
        detailVC.favoriteViewModel = favoriteViewModel
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

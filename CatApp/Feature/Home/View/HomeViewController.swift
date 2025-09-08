//
//  HomeViewController.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import RxSwift
import RxCocoa
import SkeletonView
import SnapKit
import SideMenu

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var sideMenuViewController = ProfileViewController()
    
    private let disposeBag = DisposeBag()
    private var viewModel: HomeViewModelProtocol
    private let favoriteViewModel = FavoriteCatViewModel()
    private var sideMenu: SideMenuNavigationController?
    
    private var catsData: [CatBreedResponse] = []
    private var searchCatsData: [CatResponse] = []
    private var searchActive = false
    private var isFetchingMore = false
    private var shouldAnimation = true
    
    private var isGrid = true {
        didSet {
            collectionView.reloadData()
            updateLayout()
        }
    }
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = LocalizationManager.shared.t("not_found")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        
        let button = UIButton(type: .system)
        button.setTitle(LocalizationManager.shared.t("back"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        view.addSubview(label)
        view.addSubview(button)
        
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }
        
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(12)
        }
        
        button.addTarget(self, action: #selector(backToList), for: .touchUpInside)
        
        return view
    }()
    
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupSideMenu()
        
        collectionView.isSkeletonable = true
        collectionView.showAnimatedGradientSkeleton()
        view.isSkeletonable = true
        emptyStateView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.collectionView.stopSkeletonAnimation()
            [self.titleLabel, self.profileButton, self.toggleButton, self.searchBar, self.collectionView, self.subLabel].forEach {
                $0.hideSkeleton()
            }
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldAnimation {
            shouldAnimation = false
            [titleLabel, profileButton, toggleButton, searchBar, collectionView, subLabel].forEach {
                $0.showAnimatedGradientSkeleton()
            }
        }
    }
    
    private func setupView() {
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        sideMenu?.delegate = self
        collectionView.register(UINib(nibName: "CatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CatCollectionViewCell")
        updateLayout()
        
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .languageChanged, object: nil
        )
    }
    
    @objc private func languageDidChange() {
        setupTexts()
    }
    
    func setupTexts() {
        subLabel.text = LocalizationManager.shared.t("subLabelHome_")
        searchBar.placeholder = LocalizationManager.shared.t("searchplaceholder_")
        
    }
    
    private func setupSideMenu() {
        let menuVC = ProfileViewController()
        
        let menu = SideMenuNavigationController(rootViewController: menuVC)
        menu.leftSide = true
        menu.presentationStyle = .menuSlideIn
        menu.presentationStyle.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        menu.presentationStyle.presentingEndAlpha = 0.5
        
        sideMenu = menu
    }
    
    private func bindViewModel() {
        viewModel.cats
            .drive(onNext: { [weak self] cats in
                guard let self = self else { return }
                
                guard !self.searchActive else { return }
                
                self.collectionView.hideSkeleton()
                
                self.catsData.append(contentsOf: cats)
                self.updateEmptyState(isEmpty: self.catsData.isEmpty)
                self.collectionView.reloadData()
                self.isFetchingMore = false
                
                [self.titleLabel, self.profileButton, self.toggleButton, self.searchBar, self.collectionView, self.subLabel].forEach {
                    $0.hideSkeleton()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.catsSearch
            .drive(onNext: { [weak self] cats in
                guard let self = self else { return }
                
                guard self.searchActive else { return }
                
                self.collectionView.hideSkeleton()
                
                self.searchCatsData = cats
                self.updateEmptyState(isEmpty: cats.isEmpty)
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] loading in
                guard self != nil else { return }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .drive(onNext: { [weak self] error in
                guard self != nil else { return }
                
                if let error = error {
                    print("Error: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    @objc private func backToList() {
        searchActive = false
        searchCatsData = []
        emptyStateView.isHidden = true
        collectionView.isHidden = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        
    }
    
    @objc private func toggleTapped() {
        isGrid.toggle()
        let icon = isGrid ? "square.grid.2x2" : "list.bullet"
        toggleButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func profileTapped() {
        if let menu = sideMenu {
            present(menu, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchActive ? searchCatsData.count : catsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCatCell(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dataCount = searchActive ? searchCatsData.count : catsData.count
        if indexPath.item == dataCount {
            return CGSize(width: width, height: 60)
        }
        return isGrid ? CGSize(width: (width / 2) - 8, height: 110)
        : CGSize(width: width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageUrl: String
        let catId: String
        
        if searchActive {
            let cat = searchCatsData[indexPath.row]
            catId = cat.breeds?.first?.id ?? ""
            imageUrl = cat.url ?? ""
        } else {
            let cat = catsData[indexPath.row]
            catId = cat.id ?? ""
            imageUrl = cat.image?.url ?? ""
        }
        
        let detailVM = CatDetailViewModel(id: catId, imageUrl: imageUrl)
        let detailVC = DetailCatViewController(viewModel: detailVM, favoriteViewModel: self.favoriteViewModel)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !searchActive else { return }
        let total = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row == total - 2, !isFetchingMore {
            isFetchingMore = true
            viewModel.loadMoreCats()
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            searchActive = false
            collectionView.reloadData()
            return
        }
        searchActive = true
        viewModel.searchCats(breedId: text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchCatsData = []
        collectionView.reloadData()
    }
}

extension HomeViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "CatCollectionViewCell"
    }
}

extension HomeViewController {
    private func configureCatCell(for indexPath: IndexPath) -> CatCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CatCollectionViewCell",
            for: indexPath
        ) as? CatCollectionViewCell else {
            return CatCollectionViewCell()
        }
        
        if searchActive {
            let cat = searchCatsData[indexPath.row]
            let vm = CardCatViewModel(
                id: cat.breeds?.first?.id ?? "",
                imageUrl: cat.url
            )
            cell.viewModel = vm
        } else {
            let cat = catsData[indexPath.row]
            let vm = CardCatViewModel(
                id: cat.id ?? "",
                imageUrl: cat.image?.url
            )
            cell.viewModel = vm
        }
        
        return cell
    }
}

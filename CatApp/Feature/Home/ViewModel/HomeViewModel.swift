//
//  HomeViewModel.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelProtocol {
    var cats: Driver<[CatBreedResponse]> { get }
    var catsSearch: Driver<[CatResponse]> { get }
    
    var isLoading: Driver<Bool> { get }
    var errorMessage: Driver<String?> { get }
    
    func fetchCats(limit: Int, page: Int)
    func searchCats(breedId: String, limit: Int)
    func loadMoreCats()
    
}

class HomeViewModel: HomeViewModelProtocol {
    
    private let apiService: GenerateApiProtocol
    private let disposeBag = DisposeBag()
    
    private var currentPage = 1
    private var currentLimit = 10
    private var currentBreedId: String? = nil
    
    private let catsRelay = BehaviorRelay<[CatBreedResponse]>(value: [])
    private let catsRelaySearch = BehaviorRelay<[CatResponse]>(value: [])
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String?>(value: nil)
    
    var cats: Driver<[CatBreedResponse]> { catsRelay.asDriver() }
    var catsSearch: Driver<[CatResponse]> { catsRelaySearch.asDriver() }
    var isLoading: Driver<Bool> { loadingRelay.asDriver() }
    var errorMessage: Driver<String?> { errorRelay.asDriver() }
    
    init(apiService: GenerateApiProtocol = GenerateApiExt.shared) {
        self.apiService = apiService
    }
    
    func fetchCats(limit: Int, page: Int) {
        currentLimit = limit
        currentPage = page
        currentBreedId = nil
        requestCats(limit: limit, page: page)
    }
    
    func searchCats(breedId: String, limit: Int) {
        currentLimit = limit
        currentBreedId = breedId
        requestSearchCats(breedId: breedId, limit: limit)
    }
    
    func loadMoreCats() {
        if let breedId = currentBreedId {
            currentLimit += 10
            requestSearchCats(breedId: breedId, limit: currentLimit)
        } else {
            currentPage += 1
            requestCats(limit: currentLimit, page: currentPage)
        }
    }
    
    private func requestCats(limit: Int, page: Int) {
        loadingRelay.accept(true)
        apiService.getCats(limit: limit, page: page)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                self.loadingRelay.accept(false)
                var currentData = self.catsRelay.value
                currentData.append(contentsOf: result)
                self.catsRelay.accept(currentData)
            } onFailure: { [weak self] error in
                self?.loadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    private func requestSearchCats(breedId: String, limit: Int) {
        loadingRelay.accept(true)
        apiService.getSearchCats(id: breedId, limit: limit)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                self.loadingRelay.accept(false)
                self.catsRelaySearch.accept(result)
            } onFailure: { [weak self] error in
                self?.loadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
}

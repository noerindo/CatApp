//
//  CatDetailViewModel.swift
//  CatApp
//
//  Created by Phincon on 06/09/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol CatDetailViewModelProtocol {
    var catDetail: Driver<CatDetailModel?> { get }
    var isLoading: Driver<Bool> { get }
    var errorMessage: Driver<String?> { get }
}

class CatDetailViewModel: CatDetailViewModelProtocol {
    
    private let apiService: GenerateApiProtocol
    private let disposeBag = DisposeBag()
    
    private let catDetailRelay = BehaviorRelay<CatDetailModel?>(value: nil)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String?>(value: nil)
    
    var catDetail: Driver<CatDetailModel?> { catDetailRelay.asDriver() }
    var isLoading: Driver<Bool> { isLoadingRelay.asDriver() }
    var errorMessage: Driver<String?> { errorRelay.asDriver() }
    
    private let id: String
    private let imageUrl: String
    
    init(id: String, imageUrl: String, apiService: GenerateApiProtocol = GenerateApiExt.shared) {
        self.id = id
        self.imageUrl = imageUrl
        self.apiService = apiService
        fetchDetail()
    }
    
    private func fetchDetail() {
        isLoadingRelay.accept(true)
        apiService.getDetail(id: id)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)
                
                if let cat = result.first {
                    let model = CatDetailModel(
                        id: cat.id ?? "",
                        name: cat.breeds?.first?.name ?? "",
                        description: cat.breeds?.first?.description ?? "",
                        temperament: cat.breeds?.first?.temperament ?? "",
                        imageUrl: self.imageUrl
                    )
                    self.catDetailRelay.accept(model)
                }
                
            } onFailure: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
}

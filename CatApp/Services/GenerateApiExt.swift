//
//  GenerateApiExt.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation
import Alamofire
import RxSwift

protocol GenerateApiProtocol {
    func getCats(limit: Int, page: Int) -> Single<[CatBreedResponse]>
    func getSearchCats(id: String) -> Single<[CatResponse]>
    func getDetail(id: String) -> Single<[CatResponse]>
}

struct ConfigAPI {
    static var hosts: String = "https://api.thecatapi.com/v1/"
}

class endPointAPI {
    
    enum KeyAPI {
        case getCats(limit: Int, page: Int)
        case getSearchCats(id: String)
        case getDetail(id: String)
        
        func path() -> String {
            switch self {
            case .getCats(let limit, let page):
                return "breeds?limit=\(limit)&page=\(page)"
            case .getSearchCats(let id):
                return "images/search?breed_ids=\(id)&limit=10"
            case .getDetail(id: let id):
                return "images/search?breed_ids=\(id)"
            }
        }
        
        var url: String {
            return ConfigAPI.hosts + path()
        }
    }
    
    static func getFullURL(for key: KeyAPI) -> String {
        return key.url
    }
}

public class GenerateApiExt: GenerateApiProtocol {
    public static let shared = GenerateApiExt()
    private init() {}
    
    private let headers: HTTPHeaders = [
           "x-api-key": "live_BrwJyXPCxoFXd0AVFwym5n4uU8SJrH144jXD1Hct3RzgHamWhVYmK4kjxHlRme2y"
       ]
    
    // MARK: Cats List
    func getCats(limit: Int, page: Int) -> Single<[CatBreedResponse]> {
        return Single.create { single in
            let url = endPointAPI.getFullURL(for: .getCats(limit: limit, page: page))
            
            let request = AF.request(url, method: .get, headers: self.headers)
                .validate()
                .responseDecodable(of: [CatBreedResponse].self) { response in
                    switch response.result {
                    case .success(let cats):
                        single(.success(cats))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: Search Cats by Breed
    func getSearchCats(id: String) -> Single<[CatResponse]> {
        return Single.create { single in
            let url = endPointAPI.getFullURL(for: .getSearchCats(id: id))
            
            let request = AF.request(url, method: .get, headers: self.headers)
                .validate()
                .responseDecodable(of: [CatResponse].self) { response in
                    switch response.result {
                    case .success(let cats):
                        single(.success(cats))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: Cats List
    func getDetail(id: String) -> Single<[CatResponse]> {
        return Single.create { single in
            let url = endPointAPI.getFullURL(for: .getDetail(id: id))
            
            let request = AF.request(url, method: .get, headers: self.headers)
                .validate()
                .responseDecodable(of: [CatResponse].self) { response in
                    switch response.result {
                    case .success(let cats):
                        single(.success(cats))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

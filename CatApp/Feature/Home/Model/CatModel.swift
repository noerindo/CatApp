//
//  CatModel.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation

struct CatResponse: Codable {
    let id: String?
    let url: String?
    let breeds: [CatBreedResponse]?
}

struct CatBreedResponse: Codable {
    let id: String?
    let name: String?
    let temperament: String?
    let description: String?
    let reference_image_id: String
    let image: CatImage?
}

struct CatImage: Codable {
    let id: String?
    let url: String?
}

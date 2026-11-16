//
//  CompanyDetailsModel.swift
//  Esterad
//
//  Created by Haneen on 20/11/2025.
//

import Foundation

// MARK: - Root Response -
struct DelegateResponse: Codable {
    let delegate: Delegate
}

// MARK: - Delegate -
struct Delegate: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let logo: String?
    let lat: String?
    let long: String?
    let address: String?
    let rate: String?
    let categories: [DelegateCategory]?
    let desc: String?
    let products: [SubcategoryItem]?
    let reviews: [ReviewsModel]?
    let roomId: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, email, logo, lat, long, address, rate, categories, desc, products, reviews
        case roomId = "room_id"
    }
}

// MARK: - Category -
struct DelegateCategory: Codable {
    let id: Int?
    let name: String?
    let slug: String?
    let image: String?
}

extension DelegateCategory :SelectionModelPicker {    
    var pickerId: Int { id  ?? 0 }
    var pickerName: String { name ?? "" }
    var pickerSlug : String {slug ?? "" }
}

// MARK: - Review  -

struct ReviewsModelResponse : Codable {
    let reviews : [ReviewsModel]
}

struct ReviewsModel: Codable {
    let id : Int?
    let username : String?
    let userAvatar : String?
    let rate : String?
    let comment : String?
    let createdAt : String?
    
    enum CodingKeys: String, CodingKey {
        case id, username = "user_name", userAvatar = "user_avatar", rate, comment, createdAt = "created_at"
    }
}

struct DelegateProductsResponse : Codable {
    let products : [SubcategoryItem]
    let pagination : Pagination
}

enum HeaderTypes {
    case product
    case rate
}

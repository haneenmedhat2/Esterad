//
//  HomeModel.swift
//  Esterad
//
//  Created by Haneen on 11/11/2025.
//

import Foundation

//MARK: - Update Location -

struct UpdateLocationModel : Codable {
    let lat : Double
    let long : Double
    let address : String
}

// MARK: - HomeResponse -

struct HomeResponse: Codable {
    let numNotSeenNotifications: Int?
    let ads: [Ad]?
    let categories: [Category]?

    enum CodingKeys: String, CodingKey {
        case numNotSeenNotifications = "num_not_seen_notifications"
        case ads, categories
    }
}

// MARK: - Ad -

struct Ad: Codable {
    let id: Int?
    let title: String?
    let content: String?
    let image: String?
    let cover: String?
    let linkType : AdsLinkType
    let productId : Int?
    let delegateId : Int?
    let categoryId : Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, image, cover
        case linkType = "link_type"
        case productId = "product_id"
        case delegateId = "delegate_id"
        case categoryId = "category_id"
    }
}

enum AdsLinkType : String , Codable {
    case product
    case delegate
    case none
}

// MARK: - Category -

struct Category: Codable {
    let id: Int?
    let name: String?
    let slug: String?
    let image: String?
    let desc : String?
}

extension Category {
    var categoryKind: CategoryKind {
        CategoryKind.from(slug: slug)
    }
    
    var productIcon: String {
        categoryKind.productIcon
    }
    
    var companyIcon: String {
        categoryKind.companyIcon
    }
}

//MARK: - Category Kind -

enum CategoryKind {
    case car
    case spareParts
    case furniture
    case other

    static func from(slug: String?) -> CategoryKind {
        switch (slug ?? "").lowercased() {
        case "cars", "car":
            return .car
        case "spare-parts", "spareparts":
            return .spareParts
        case "furniture":
            return .furniture
        default:
            return .other
        }
    }

    var productIcon: String {
        switch self {
        case .car, .spareParts:
            return "carPlaceholder"
        case .furniture, .other:
            return "furniturePlaceholder"
        }
    }

    var companyIcon: String {
        switch self {
        case .car, .spareParts:
            return "companyPlaceholder"
        case .furniture, .other:
            return "furnitureCompany"
        }
    }
}

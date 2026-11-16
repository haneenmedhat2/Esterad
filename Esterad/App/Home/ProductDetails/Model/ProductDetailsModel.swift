//
//  ProductDetailsModel.swift
//  Esterad
//
//  Created by Haneen on 19/11/2025.
//

import Foundation

struct ProductResponse: Codable {
    let product: Product?
}

struct Product: Codable {
    let id: Int?
    let images: [ProductImage]?
    let name: String?
    let desc: String?
    let price: String?
    let discountPrice: String?
    let categoryId: Int?
    let categoryName: String?
    let carCompanyId: Int?
    let carCompanyName: String?
    let carModelId: Int?
    let carModelName: String?
    let cartypeId: Int?
    let carTypeName: String?
    let status: String?
    let transmission: String?
    let fuelType: String?
    let engineCapacity: String?
    let mainSectionId: Int?
    let mainSectionName: String?
    let subsectionId: Int?
    let subsectionName: String?
    let importingCountryId: Int?
    let importingCountryName: String?
    let customsFees: String?
    let addedValue: String?
    let downPaymentPrice: String?
    let initialDeliveryPrice: String?
    let minEstimatedDeliveryDuration: String?
    let maxEstimatedDeliveryDuration: String?
    let hasDiscount : Bool?
    let fuelTypeText : String?
    let transmissionText : String?
    let totalPrice : String?
    let isPurchased : Bool?

    
    enum CodingKeys: String, CodingKey {
        case id
        case images
        case name
        case desc
        case price
        case discountPrice = "discount_price"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case carCompanyId = "car_company_id"
        case carCompanyName = "car_company_name"
        case carModelId = "car_model_id"
        case carModelName = "car_model_name"
        case cartypeId = "cartype_id"
        case carTypeName = "car_type_name"
        case status
        case transmission
        case fuelType = "fuel_type"
        case engineCapacity = "engine_capacity"
        case mainSectionId = "main_section_id"
        case mainSectionName = "main_section_name"
        case subsectionId = "subsection_id"
        case subsectionName = "subsection_name"
        case importingCountryId = "importing_country_id"
        case importingCountryName = "importing_country_name"
        case customsFees = "customs_fees"
        case addedValue = "added_value"
        case downPaymentPrice = "down_payment_price"
        case initialDeliveryPrice = "initial_delivery_price"
        case minEstimatedDeliveryDuration = "min_estimated_delivery_duration"
        case maxEstimatedDeliveryDuration = "max_estimated_delivery_duration"
        case hasDiscount = "has_discount"
        case fuelTypeText = "fuel_type_text"
        case transmissionText = "transmission_text"
        case totalPrice = "total_price"
        case isPurchased = "is_purchased"
    }
}

struct ProductImage : Codable {
    let id : Int?
    let image : String?
    var isSelected : Bool?
}

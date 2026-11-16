//
//  CategoryDetailsModel.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import Foundation

//MARK: - homeMode Types -

enum HomeModeTypes: CaseIterable {
    case products
    case companies
    
    var id: Int {
        switch self {
        case .products: return 0
        case .companies: return 1
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .products: return "normal_requests".localized
        case .companies: return "special_requests".localized
        }
    }
    
    var apiName : String {
        switch self {
        case .products:
            return "product"
        case .companies:
            return "company"
        }
    }
}

//MARK: - Subcategories Model -

struct SubcategoriesModel: Codable {
    var type: String?
    var categorySlug: String?
    var search: String?
    var rate: String?
    var mainSectionId: Int?
    var subsectionId: Int?
    var carCompanyId: Int?
    var carTypeId: Int?
    var fuelType: String?
    var transmission: String?
    var status: String?
    var importingCountryId: Int?
    var engineCapacity: String?
    var carModelId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case categorySlug = "category_slug"
        case search
        case rate
        case mainSectionId = "main_section_id"
        case subsectionId = "subsection_id"
        case carCompanyId = "car_company_id"
        case carTypeId = "car_type_id"
        case fuelType = "fuel_type"
        case transmission
        case status
        case importingCountryId = "importing_country_id"
        case engineCapacity = "engine_capacity"
        case carModelId = "car_model_id"
    }
}

struct SubcategoriesResponse: Codable {
    let subcategories: [SubcategoryItem]
    let pagination: Pagination
}

struct SubcategoryItem: Codable {
    let id: Int?
    let image: String?
    let name: String?
    let desc: String?
    let price: String?
    let discountPrice: String?
    let hasDiscount: Bool?
    let rate : String?
    let logo : String?
    let isPurchased : Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case image
        case name
        case desc
        case price
        case discountPrice = "discount_price"
        case hasDiscount = "has_discount"
        case rate
        case logo
        case isPurchased = "is_purchased"
    }
}

struct Pagination: Codable {
    let total: Int?
    let count: Int?
    let perPage: Int?
    let nextPageURL: String?
    let prevPageURL: String?
    let currentPage: Int
    let totalPages: Int
    var isLastPage: Bool {
        currentPage >= totalPages
    }
    
    enum CodingKeys: String, CodingKey {
        case total
        case count
        case perPage = "per_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "perv_page_url"
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }
}

struct ImportingCountriesResponse : Codable {
    let countries: [PickerModel]
}

struct CarCompaniesResponse : Codable {
    let carCompanies: [PickerModel]
    
    enum CodingKeys: String, CodingKey {
        case carCompanies = "car_companies"
    }
}

struct CarTypeResponse : Codable {
    let carTypes: [PickerModel]
    
    enum CodingKeys: String, CodingKey {
        case carTypes = "car_types"
    }
}

struct CarModelResponse : Codable {
    let carModels: [PickerModel]
    
    enum CodingKeys: String, CodingKey {
        case carModels = "car_models"
    }
}

struct MainSectionResponse : Codable {
    let mainSections: [PickerModel]
    
    enum CodingKeys: String, CodingKey {
        case mainSections = "main_sections"
    }
}

struct SubSectionResponse : Codable {
    let subSections: [PickerModel]
    
    enum CodingKeys: String, CodingKey {
        case subSections = "sub_sections"
    }
}

struct PickerModel : Codable {
    let id : Int?
    let name : String?
    let mainSectionId : Int?
    let carTypeId  : Int?
    let apiValue : String?
    let image : String?
    let slug : String?
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mainSectionId = "main_section_id"
        case carTypeId = "car_type_id"
        case apiValue
        case image
        case slug 
    }
}

enum ProductState : CaseIterable {
    case new
    case used
    
    var id: Int {
        switch self {
        case .new:
            return 0
        case .used:
            return 1
        }
    }
    
    var stringValue: String {
        switch self {
        case .new:
            return "new".localized
        case .used:
            return "used".localized
        }
    }
    
    var apiValue: String {
        switch self {
        case .new:
            return "new"
        case .used:
            return "used"
        }
    }
    
    var pickerModel: PickerModel {
            return PickerModel(
                id: self.id,
                name: self.stringValue,
                mainSectionId: nil,
                carTypeId: nil,
                apiValue: self.apiValue,
                image: nil,
                slug: nil
            )
        }
    
    static var pickerModels: [PickerModel] {
        return ProductState.allCases.map { $0.pickerModel }
    }
}

enum CarGear : CaseIterable {
    case manual
    case automatic
    
    var id: Int {
        switch self {
        case .manual:
            return 0
        case .automatic:
            return 1
        }
    }
    
    var stringValue: String {
        switch self {
        case .manual:
            return "manual".localized
        case .automatic:
            return "automatic".localized
        }
    }
    
    var apiValue: String {
        switch self {
        case .manual:
            return "manual"
        case .automatic:
            return "automatic"
        }
    }
    
    var pickerModel: PickerModel {
            return PickerModel(
                id: self.id,
                name: self.stringValue,
                mainSectionId: nil,
                carTypeId: nil,
                apiValue: self.apiValue,
                image: nil,
                slug: nil
                
            )
        }
    
    static var pickerModels: [PickerModel] {
        return  CarGear.allCases.map { $0.pickerModel }
    }
}

enum FuelType : CaseIterable {
    case petrol
    case diesel
    case electric
    case hybrid
    case gas
    
    var id: Int {
        switch self {
        case .petrol:
            return 0
        case .diesel:
            return 1
        case .electric:
            return 2
        case .hybrid:
            return 3
        case .gas:
            return 4
        }
    }
    
    var stringValue: String {
        switch self {
        case .petrol:
            return "petrol".localized
        case .diesel:
            return "diesel".localized
        case .electric:
            return "electric".localized
        case .hybrid:
            return "hybrid".localized
        case .gas:
            return "gas".localized
        }
    }
    
    var apiValue: String {
        switch self {
        case .petrol:
            return "petrol"
        case .diesel:
            return "diesel"
        case .electric:
            return "electric"
        case .hybrid:
            return "hybrid"
        case .gas:
            return "gas"
        }
    }
    
    var pickerModel: PickerModel {
            return PickerModel(
                id: self.id,
                name: self.stringValue,
                mainSectionId: nil,
                carTypeId: nil,
                apiValue: self.apiValue,
                image: nil,
                slug: nil
            )
        }
    
    static var pickerModels: [PickerModel] {
        return FuelType.allCases.map { $0.pickerModel }
    }
}

enum PickerType {
    case importedCountry
    case carBrand
    case carType
    case carModel
    case state
    case transmissionType
    case fuelType
    case mainCategory
    case category
}

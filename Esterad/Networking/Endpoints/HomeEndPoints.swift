//
//  HomeEndPoints.swift
//  Esterad
//
//  Created by Haneen on 08/09/2025.
//

import Foundation

struct HomeEndPoints {
    private init() {}
}

extension HomeEndPoints {
    
    static func getHomeData() -> Endpoint<BaseResponse<HomeResponse>>{
        return .init(
            method: .get,
            path: "home"
        )
    }
    
    static func updateLocation(model: UpdateLocationModel) -> Endpoint<BaseResponse<User>>{
        return .init(
            method: .post,
            path: "update-location",
            body: [
                "lat": model.lat,
                "long": model.long,
                "address": model.address
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getCategories() -> Endpoint<BaseResponse<CategoryResponse>>{
        return .init(
            method: .get,
            path: "categories"
        )
    }

    static func getSubcategories(model: SubcategoriesModel,page : Int)
    -> Endpoint<BaseResponse<SubcategoriesResponse>> {

        return .init(
            method: .get,
            path: "subcategories",
            queries: [
                "type": model.type,
                "category_slug": model.categorySlug,
                "search": model.search,
                "rate": model.rate,
                "main_section_id": model.mainSectionId,
                "subsection_id": model.subsectionId,
                "car_company_id": model.carCompanyId,
                "car_type_id": model.carTypeId,
                "fuel_type": model.fuelType,
                "transmission": model.transmission,
                "status": model.status,
                "importing_country_id": model.importingCountryId,
                "engine_capacity": model.engineCapacity,
                "car_model_id": model.carModelId,
                "page" : page
            ]
        )
    }
    
    static func getImportingCountries() -> Endpoint<BaseResponse<ImportingCountriesResponse>>{
        return .init(
            method: .get,
            path: "importing-countries"
        )
    }
    
    static func getCarCompanies() -> Endpoint<BaseResponse<CarCompaniesResponse>>{
        return .init(
            method: .get,
            path: "car-companies"
        )
    }
    
    static func getCarType() -> Endpoint<BaseResponse<CarTypeResponse>>{
        return .init(
            method: .get,
            path: "car-types"
        )
    }
    
    static func getCarModel(carTypeId: Int) -> Endpoint<BaseResponse<CarModelResponse>>{
        return .init(
            method: .get,
            path: "car-models",
            queries: [
                "cartype_id" : carTypeId
            ]
        )
    }
    
    static func getMainSection() -> Endpoint<BaseResponse<MainSectionResponse>>{
        return .init(
            method: .get,
            path: "main-sections"
        )
    }
    
    static func getSubSection(mainSectionId : Int) -> Endpoint<BaseResponse<SubSectionResponse>>{
        return .init(
            method: .get,
            path: "sub-sections",
            queries: [
                "main_section_id" : mainSectionId
            ]
        )
    }
    
    static func getProductDetails(productId : Int) -> Endpoint<BaseResponse<ProductResponse>>{
        return .init(
            method: .get,
            path: "product-details",
            queries: [
                "product_id" : productId
            ]
        )
    }
    
    static func getCompanyDetails(delegateId : Int) -> Endpoint<BaseResponse<DelegateResponse>>{
        return .init(
            method: .get,
            path: "delegate-details",
            queries: [
                "delegate_id" : delegateId            ]
        )
    }
    
    static func getDelegateProducts(model : AllProductsModel, page : Int) -> Endpoint<BaseResponse<DelegateProductsResponse>>{
        return .init(
            method: .get,
            path: "delegate-products",
            queries: [
                "delegate_id" : model.delegateId,
                "category_slug" : model.categorySlug,
                "search" : model.search,
                "page" : page
            ]
        )
    }
    
    static func getUserReviews() -> Endpoint<BaseResponse<ReviewsModelResponse>>{
        return .init(
            method: .get,
            path: "user-reviews",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getDelegateReviews(delegateId : Int ) -> Endpoint<BaseResponse<ReviewsModelResponse>>{
        return .init(
            method: .get,
            path: "delegate-reviews",
            queries: [
                "delegate_id" : delegateId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func createSpecialOrder(model : SpecialRequestModel) -> Endpoint<BaseResponse<SpecialRequestResponse>>{
        return .init(
            method: .post,
            path: "create-order",
            body: [
                "delegate_id" : model.delegateId,
                "category_id" : model.categoryId,
                "type" : model.type,
                "product_type" : model.productType,
                "product_desc" : model.productDesc,
                "product_qty" : model.productQty,
                "expected_budget" : model.expectedBudget,
                "notes" : model.notes
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func createNormalOrder(model : PaymentModel) -> Endpoint<BaseResponse<SpecialRequestResponse>>{
        return .init(
            method: .post,
            path: "create-order",
            body: [
                "product_id" : model.productId,
                "type" : model.type,
                "payment_type" : model.paymentType
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getSpecialOrderPlaceholder() -> Endpoint<BaseResponse<SpecialOrderPlaceholderRes>>{
        return .init(
            method: .get,
            path: "special-order-placeholder"
        )
    }
    
    static func askProductAvailability(productId : Int) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "ask-product-availability",
            body: [
                "product_id" : productId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
}

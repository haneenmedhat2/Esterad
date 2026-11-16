//
//  OrderDetailsModel.swift
//  Esterad
//
//  Created by Haneen on 01/12/2025.
//

import Foundation

struct OrderDetailsResponse: Codable {
    let order: OrderDetailsModel
}

struct OrderDetailsModel: Codable {
    
    let id: Int?
    let createdAt: String?
    let status: String?
    let statusText: String?
    let type: String?
    let categoryName: String?
    let productType: String?
    let productQty: Int?
    let expectedBudget: String?
    let productName: String?
    let productImage: String?
    let paymentMethod: PaymentMethodModel?
    let paymentStatus: Bool?
    let price: String?
    let deliveryPrice: String?
    let downPaymentPrice: String?
    let appPercentage: String?
    let customsFees: String?
    let addedValue: String?
    let totalPrice: String?
    let delegateId: Int?
    let delegateName: String?
    let delegateLogo: String?
    let userId: Int?
    let userName: String?
    let userAvatar: String?
    let roomId: Int?
    let deliveryOffer: DeliveryOffer?
    let closeReason: String?
    let isRated: Bool?
    let reviews: [ReviewResponse]?
    let productDesc : String?
    let notes : String?
    let delegateNotes : String?
    
    var orderStatusCase:OrderStatus {
        if status == "open" {
            return .open
        }else if status == "accepted" {
            return .accepted
        }else if status == "refused" {
            return .refused
        }else if status == "rejected_cost" {
            return .rejectedCost
        }else if status == "inprogress" {
            return .inprogress
        }else if status == "pending_confirmation"{
            return .pendingConfirmation
        }else if status ==  "finished" {
            return .finished
        }else if status == "closed" {
            return .closed
        }else {
            return .open
        }
    }
    
    var offerStatus : OfferStatus {
        if deliveryOffer?.status == "new" {
            return .new
        }else if deliveryOffer?.status == "rejected" {
            return .rejected
        }else if deliveryOffer?.status == "changed" {
            return .changed
        } else {
            return .new
        }
    }
    
    var orderType : OrderType {
        if type == "normal" {
            return .normal
        } else {
            return .special
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case status
        case statusText = "status_text"
        case type
        case categoryName = "category_name"
        case productType = "product_type"
        case productQty = "product_qty"
        case expectedBudget = "expected_budget"
        case productName = "product_name"
        case productImage = "product_image"
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case price
        case deliveryPrice = "delivery_price"
        case downPaymentPrice = "down_payment_price"
        case appPercentage = "app_percentage"
        case customsFees = "customs_fees"
        case addedValue = "added_value"
        case totalPrice = "total_price"
        case delegateId = "delegate_id"
        case delegateName = "delegate_name"
        case delegateLogo = "delegate_logo"
        case userId = "user_id"
        case userName = "user_name"
        case userAvatar = "user_avatar"
        case roomId = "room_id"
        case deliveryOffer = "delivery_offer"
        case closeReason = "close_reason"
        case isRated = "is_rated"
        case reviews
        case productDesc = "product_desc"
        case notes
        case delegateNotes = "delegate_notes"
    }
}
extension OrderDetailsModel {
    func toViewModel() ->  OrderDetailsViewModel {
        return .init(id: id, price: price)
    }
}

struct OrderDetailsViewModel {
    var id: Int?
    var price: String?
}

extension OrderDetailsModel {
    var hideCancelButton: Bool {
        return !(orderStatusCase == .inprogress || orderStatusCase == .open)
    }
    var hideOrderConfirmationButton: Bool {
        return orderStatusCase != .pendingConfirmation
    }
    var hideReportButton: Bool {
        return !(orderStatusCase == .inprogress || orderStatusCase == .pendingConfirmation )
    }
    var isChatActive: Bool {
        return orderStatusCase == .inprogress
    }
    var hideRateButton: Bool {
        return !(orderStatusCase == .finished && isRated != true)
    }
    var hideCancellationView : Bool {
        return !(orderStatusCase == .closed )
    }
    var hideRejectionView : Bool {
        return !(orderStatusCase == .refused )
    }
    var hideAcceptRefuseButtons : Bool {
        return !(orderStatusCase == .accepted || offerStatus == .changed )
    }
    var hideChatButton : Bool {
        return (orderStatusCase == .open || orderStatusCase == .accepted || orderStatusCase == .rejectedCost || orderStatusCase == .closed || orderStatusCase == .refused)
    }
    var hideOrderAcceptanceView : Bool {
        return !(orderStatusCase == .accepted || orderStatusCase == .rejectedCost)
    }
    var hideFinancialDetails: Bool {
        return (orderStatusCase == .open || orderStatusCase == .closed || orderStatusCase == .refused)
    }
    
    var hideSpecialOrderPaymentMethod : Bool {
        return orderStatusCase == .rejectedCost ||  orderStatusCase == .accepted
    }
}

struct PaymentMethodModel : Codable {
    let id : Int?
    let key : String?
    let name : String?
    let desc : String?
    let image : String?
}

struct ReviewResponse : Codable {}

struct ReviewModel : Codable {
    let orderId : Int?
    let secondUserId : Int?
    let rate : Double?
    let comment : String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case secondUserId = "second_user_id"
        case rate
        case comment
    }
}

struct DeliveryOffer : Codable {
    let delegateAvatar : String?
    let delegateName : String?
    let id : Int?
    let notes : String?
    let price : String?
    let status : String?
    
    enum CodingKeys: String, CodingKey {
        case delegateAvatar = "delegate_avatar"
        case delegateName = "delegate_name"
        case id
        case notes
        case price
        case status
    }
}


enum OfferStatus {
    case new
    case rejected
    case changed
    
    var note : String {
        switch self {
        case .new:
            return "order_accepted_by_company".localized
        case .rejected:
            return "offer_rejected_waiting_company_update".localized
        case .changed:
            return "price_updated_by_company".localized
        }
    }
}

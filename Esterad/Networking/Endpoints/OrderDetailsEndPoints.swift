//
//  ReservationDetailsEndPoints.swift
//  Waraqa
//
//  Created by Haneen on 21/09/2025.
//

import Foundation

struct OrderDetailsEndPoints {
    private init() {}
}

extension OrderDetailsEndPoints {
    
    static func getOrderDetials(orderId : Int) -> Endpoint<BaseResponse<OrderDetailsResponse>>{
        return .init(
            method: .get,
            path: "user-single-order",
            queries: [
                "order_id" : orderId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func cancelOrder(orderId : Int,cancelReason: String ) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "cancel-order",
            body: [
                "order_id" : orderId,
                "reason" : cancelReason
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func confirmOrder(orderId : Int) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "user-confirm-order",
            body: [
                "order_id" : orderId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func rejectOrder(offerId : Int , reason : String) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "user-reject-offer",
            body: [
                "offer_id" : offerId,
                "reason" : reason
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func acceptOffer(offerId : Int , paymentType : String) -> Endpoint<BaseResponse<PayTabsModel>>{
        return .init(
            method: .post,
            path: "user-accept-offer",
            body: [
                "offer_id" : offerId,
                "payment_type" : paymentType
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
//    static func payOrder(token: String ,orderId : Int,payType: Int ) -> Endpoint<BaseResponse<String>>{
//        return .init(
//            method: .post,
//            path: "user/pay-order",
//            body: [
//                "order_id" : orderId,
//                "pay_type" : payType
//            ],
//            headerType: .authorized(token: Session.token ?? "")
//        )
//    }

    static func rateOrder(model:ReviewModel) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "review-delegate",
            body: [
                "order_id" : model.orderId,
                "seconduser_id" : model.secondUserId,
                "rate" : model.rate,
                "comment" : model.comment
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
}

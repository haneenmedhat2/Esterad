//
//  ReservationsEndPoints.swift
//  Waraqa
//
//  Created by Haneen on 21/09/2025.
//

import Foundation

struct OrdersEndPoints {
    private init() {}
}

extension OrdersEndPoints {
    
    static func getOrder(page: Int ,status: String, type: String) -> Endpoint<BaseResponse<OrdersResponse>>{
        return .init(
            method: .get,
            path: "user-orders",
            queries: [
                "page": page,
                "status" : status,
                "type" : type
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
}


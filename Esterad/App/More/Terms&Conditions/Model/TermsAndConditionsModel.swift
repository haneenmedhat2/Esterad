//
//  TermsAndConditionsModel.swift
//  Esterad
//
//  Created by Haneen on 10/11/2025.
//

import Foundation

struct TermsAndConditionsResponse : Codable {
    let terms : String
}


enum TermsFlow {
    case register
    case order(productId: Int, price: String)
    case chat(roomId : Int , senderName : String)
    case companyChat(providerId: Int, senderName: String, response: BaseResponse<SingleRoomResponse>)
    case more
}

enum TermsAction {
    case goToPayment(productId: Int, price: String)
    case goToChat(roomId : Int , senderName : String)
    case goToCompanyChat(providerId: Int, senderName: String, response: BaseResponse<SingleRoomResponse>)
}

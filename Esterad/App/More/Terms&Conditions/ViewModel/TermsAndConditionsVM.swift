//
//  TermsAndConditionsVM.swift
//  Esterad
//
//  Created by Haneen on 10/11/2025.
//

import Foundation
import Combine

protocol TermsAndConditionsVMProtocol {

    var termsAndConditionsPublisher: Published<BaseResponse<TermsAndConditionsResponse>?>.Publisher { get }
    var actionPublisher: Published<TermsAction?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
            
    var model : TermsFlow { get }
    
    func termsAndConditionsRequest()
    func acceptTapped()
}

final class TermsAndConditionsVM: BaseViewModel,TermsAndConditionsVMProtocol {
    
    @Published var termsAndConditions: BaseResponse<TermsAndConditionsResponse>?
    @Published var action: TermsAction?

    var termsAndConditionsPublisher: Published<BaseResponse<TermsAndConditionsResponse>?>.Publisher { $termsAndConditions }
    var actionPublisher: Published<TermsAction?>.Publisher { $action }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var model : TermsFlow

    init(model : TermsFlow){
        self.model = model
    }
    
    func termsAndConditionsRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.termsAndConditions())
                termsAndConditions = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func acceptTapped() {
        switch model {
        case .order(let id, let price):
            action = .goToPayment(productId: id, price: price)

        case .chat(let roomId , let senderName):
            action = .goToChat(roomId: roomId,senderName: senderName)

        case .companyChat(let providerId, let senderName, let response):
            action = .goToCompanyChat(
                providerId: providerId,
                senderName: senderName,
                response: response
            )

        case .register, .more:
            break
        }
    }

}
    

//
//  SpecialRequestVMProtocol.swift
//  Esterad
//
//  Created by Haneen on 27/11/2025.
//

import Foundation
import Combine

protocol PaymentVMProtocol {
    var normalPaymentPublisher: Published<BaseResponse<SpecialRequestResponse>?>.Publisher { get }
    var specialPaymentPublisher: Published<BaseResponse<PayTabsModel>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var productId : Int? { get }
    var productPrice : String { get }
    var orderType : OrderType { get }
    var offerId : Int? { get }
    var orderId : Int? { get }

    var paymentMethodList : [PaymentTypes] { get }
    var indexPath : IndexPath? { get set }
    
    func createNormalOrder(model : PaymentModel)
    func acceptOffer(paymentType : String)
    func checkOrderType(paymentType : String)
    func getSelectedPaymentMethod() -> String?
}

final class PaymentVM: BaseViewModel,PaymentVMProtocol {
 
    @Published var normalPayment: BaseResponse<SpecialRequestResponse>?
    @Published var specialPayment: BaseResponse<PayTabsModel>?

    var normalPaymentPublisher: Published<BaseResponse<SpecialRequestResponse>?>.Publisher  { $normalPayment }
    var specialPaymentPublisher: Published<BaseResponse<PayTabsModel>?>.Publisher { $specialPayment }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var paymentMethodList : [PaymentTypes] = PaymentTypes.allCases
    var indexPath : IndexPath? = nil
    var productId : Int?
    var productPrice : String
    var offerId : Int?
    var orderType : OrderType
    var orderId : Int? 

    init(productId : Int? ,productPrice : String ,offerId: Int? ,orderType : OrderType){
        self.orderType = orderType
        self.productId = productId
        self.productPrice = productPrice
        self.offerId = offerId
    }

    func createNormalOrder(model : PaymentModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.createNormalOrder(model: model))
                orderId = result.data?.orderId ?? 0
                normalPayment = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func acceptOffer(paymentType : String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.acceptOffer(offerId: offerId ?? 0, paymentType: paymentType))
                specialPayment = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func checkOrderType(paymentType : String){
        switch orderType {
        case .normal:
            createNormalOrder(model : PaymentModel(productId: productId ?? 0, paymentType: paymentType, type: orderType.apiValue))
        case .special:
            acceptOffer(paymentType: paymentType)
        }
    }


    func getSelectedPaymentMethod() -> String? {
        guard let indexPath = indexPath else {
            return nil
        }
        let model = paymentMethodList[indexPath.row]
        return model.apiValue
    }
}

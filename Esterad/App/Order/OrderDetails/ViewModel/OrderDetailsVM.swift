//
//  OrderDetailsVM.swift
//  Esterad
//
//  Created by Haneen on 01/12/2025.
//


import Foundation
import Combine

protocol OrderDetailsVMProtocol {
    
    var orderDetailsPublisher: Published<BaseResponse<OrderDetailsResponse>?>.Publisher  { get }
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { get }
    var cancelOrderPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var confirmOrderPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var rejectOrderPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var rateOrderPublisher: Published<BaseResponse<String>?>.Publisher { get }
    
    var hideCancelButton: CurrentValueSubject<Bool,Never> { get }
    var hideRateButton: CurrentValueSubject<Bool,Never> { get }
    var hideOrderConfirmationButton: CurrentValueSubject<Bool,Never> { get }
    var hideReportButton : CurrentValueSubject<Bool,Never> { get }
    var isChatActive : CurrentValueSubject<Bool,Never> { get }
    var hideCancellationView : CurrentValueSubject<Bool,Never> { get }
    var hideRejectionView : CurrentValueSubject<Bool,Never> { get }
    var hideAcceptRejectButtons : CurrentValueSubject<Bool,Never> { get }
    var hideChatButtons : CurrentValueSubject<Bool,Never> { get }
    var hideAcceptanceView : CurrentValueSubject<Bool,Never> { get }
    var hideFinancialDetails : CurrentValueSubject<Bool,Never> { get }
    var hideSpecialOrderPaymentMethod : CurrentValueSubject<Bool,Never> { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }

    var orderId : Int { get }
    var orderType : OrderType { get }
    var orderDetailsModel : OrderDetailsModel? { get }

    func getOrderDetails()
    func addNewComplaintsRequest(model:AddComplaintsModel)
    func cancelOrder(reason: String)
    func confirmOrderRequest()
    func rateOrderRequest(rate: Double , comment:String?)
    func rejectOrderRequest(reason : String)
}

final class OrderDetailsVM: BaseViewModel,OrderDetailsVMProtocol {
    @Published var orderDetails : BaseResponse<OrderDetailsResponse>?
    @Published var addNewComplaint: BaseResponse<AddComplaintsResponse>?
    @Published var cancelOrder: BaseResponse<String>?
    @Published var confirmOrder: BaseResponse<String>?
    @Published var rejectOrder: BaseResponse<String>?
    @Published var rateOrder: BaseResponse<String>?

    var orderDetailsPublisher: Published<BaseResponse<OrderDetailsResponse>?>.Publisher  { $orderDetails }
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { $addNewComplaint }
    var cancelOrderPublisher: Published<BaseResponse<String>?>.Publisher { $cancelOrder }
    var confirmOrderPublisher: Published<BaseResponse<String>?>.Publisher { $confirmOrder }
    var rejectOrderPublisher: Published<BaseResponse<String>?>.Publisher { $rejectOrder }
    var rateOrderPublisher: Published<BaseResponse<String>?>.Publisher { $rateOrder }

    var hideCancelButton: CurrentValueSubject<Bool,Never> = .init(true)
    var hideRateButton: CurrentValueSubject<Bool,Never> = .init(true)
    var hideOrderConfirmationButton: CurrentValueSubject<Bool,Never> = .init(true)
    var hideReportButton : CurrentValueSubject<Bool,Never> = .init(true)
    var isChatActive : CurrentValueSubject<Bool,Never> = .init(true)
    var hideCancellationView : CurrentValueSubject<Bool,Never> = .init(true)
    var hideRejectionView : CurrentValueSubject<Bool,Never> = .init(true)
    var hideAcceptRejectButtons : CurrentValueSubject<Bool,Never> = .init(true)
    var hideChatButtons : CurrentValueSubject<Bool,Never> = .init(true)
    var hideAcceptanceView : CurrentValueSubject<Bool,Never> = .init(true)
    var hideFinancialDetails : CurrentValueSubject<Bool,Never> = .init(true)
    var hideSpecialOrderPaymentMethod : CurrentValueSubject<Bool,Never> = .init(true)
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
        
    var orderId : Int
    var orderType : OrderType = .normal
    var orderDetailsModel : OrderDetailsModel?

    init(orderId : Int){
        self.orderId = orderId
        super.init()
    }

    func getOrderDetails(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.getOrderDetials(orderId: orderId))
                guard let details = result.data?.order else {return}
                orderDetailsModel = details
                handleHiddenButtons(order: details)
                orderDetails = result
                orderType = details.orderType
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func addNewComplaintsRequest(model:AddComplaintsModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.addNewComplaint(token: UserDefaults.accessToken ?? "", model: model))
                addNewComplaint = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func cancelOrder(reason: String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.cancelOrder(orderId: orderId, cancelReason: reason))
                cancelOrder = result
                getOrderDetails()
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func confirmOrderRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.confirmOrder( orderId: orderId))
                confirmOrder = result
                getOrderDetails()
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func rateOrderRequest(rate: Double , comment:String?){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.rateOrder(model: ReviewModel(orderId: orderId, secondUserId: orderDetailsModel?.delegateId, rate: rate, comment: comment)))
                rateOrder = result
                getOrderDetails()
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func rejectOrderRequest(reason : String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrderDetailsEndPoints.rejectOrder( offerId: orderDetailsModel?.deliveryOffer?.id ?? 0, reason: reason))
                rateOrder = result
                getOrderDetails()
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    func handleHiddenButtons(order: OrderDetailsModel ) {
        
        hideCancelButton.send(order.hideCancelButton)
        hideOrderConfirmationButton.send(order.hideOrderConfirmationButton)
        hideRateButton.send(order.hideRateButton)
        hideReportButton.send(order.hideReportButton)
        isChatActive.send(order.isChatActive)
        hideCancellationView.send(order.hideCancellationView)
        hideRejectionView.send(order.hideRejectionView)
        hideAcceptRejectButtons.send(order.hideAcceptRefuseButtons)
        hideChatButtons.send(order.hideChatButton)
        hideAcceptanceView.send(order.hideOrderAcceptanceView)
        hideFinancialDetails.send(order.hideFinancialDetails)
        hideSpecialOrderPaymentMethod.send(order.hideSpecialOrderPaymentMethod)
    }
}

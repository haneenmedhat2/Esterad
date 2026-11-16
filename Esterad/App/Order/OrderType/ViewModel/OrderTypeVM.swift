//
//  OrderTypeVM.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import Foundation
import Combine

protocol OrderTypeVMProtocol {
    
    var orderPublisher: Published<BaseResponse<OrdersResponse>?>.Publisher  { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var currentPage : Int { get }
    var isLastPage: Bool { get }
    var ordersList : [Orders] { get }
    var type : OrderType { get }
    var status : String { get set }
    var orderStatusList : [OrderStatus] { get }

    func getOrders()
    func getNormalOrderStatus()
    func getSpecialOrderStatus()
    func getOrderStatusList()
    func resetData()
}

final class OrderTypeVM: BaseViewModel,OrderTypeVMProtocol {
    @Published var orders : BaseResponse<OrdersResponse>?
    
    var orderPublisher: Published<BaseResponse<OrdersResponse>?>.Publisher  { $orders }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
        
    var currentPage:Int = 1
    var isLastPage: Bool = false
    var ordersList : [Orders] = []
    var type : OrderType
    var status : String = ""
    var orderStatusList : [OrderStatus] = []

    init(type : OrderType){
        self.type = type
        super.init()
        self.getOrderStatusList()
    }

    func getOrders(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(OrdersEndPoints.getOrder(page: currentPage, status: status, type: type.apiValue))
                
                let ordersList = result.data?.orders ?? []
                
                if self.currentPage == 1 {
                    self.ordersList.removeAll()
                    self.ordersList = ordersList
                } else {
                    self.ordersList.append(contentsOf: ordersList)
                }
                
                self.isLastPage = result.data?.pagination.isLastPage ?? false
                if !isLastPage {
                    self.currentPage += 1
                }
                
                orders = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getNormalOrderStatus(){
        status = OrderStatus.inprogress.apiValue
        orderStatusList = [.inprogress , .pendingConfirmation , .finished , .closed]
    }
    
    func getSpecialOrderStatus(){
        status = OrderStatus.open.apiValue
        orderStatusList = [ .open, .inprogress , .pendingConfirmation , .finished , .closed]
    }
    
    func getOrderStatusList(){
        switch type {
        case .normal:
            getNormalOrderStatus()
        case .special:
            getSpecialOrderStatus()
        }
    }
    
    func resetData(){
        currentPage = 1
        isLastPage = false
    }
}

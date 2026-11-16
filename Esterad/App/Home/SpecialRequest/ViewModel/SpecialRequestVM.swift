//
//  SpecialRequestVM.swift
//  Esterad
//
//  Created by Haneen on 25/11/2025.
//

import Foundation
import Combine

protocol SpecialRequestVMProtocol {
    var specialRequestPublisher: Published<BaseResponse<SpecialRequestResponse>?>.Publisher { get }
    var placeholderPublisher: Published<BaseResponse<SpecialOrderPlaceholderRes>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var delegateId : Int { get }
    var categoryId : Int { get }
    var orderId : Int { get }
    
    func getPlaceHolder()
    func createSpecialOrder(model : SpecialRequestModel)
}

final class SpecialRequestVM: BaseViewModel,SpecialRequestVMProtocol {
 
    @Published var specialRequest: BaseResponse<SpecialRequestResponse>?
    @Published var placeholder: BaseResponse<SpecialOrderPlaceholderRes>?
    
    var specialRequestPublisher: Published<BaseResponse<SpecialRequestResponse>?>.Publisher  { $specialRequest }
    var placeholderPublisher: Published<BaseResponse<SpecialOrderPlaceholderRes>?>.Publisher { $placeholder }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }

    var delegateId : Int
    var categoryId : Int
    var orderId : Int = 0

    
    init(delegateId : Int, categoryId : Int){
        self.delegateId = delegateId
        self.categoryId = categoryId
    }
    
    func getPlaceHolder(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getSpecialOrderPlaceholder())
                placeholder = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
     func createSpecialOrder(model : SpecialRequestModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.createSpecialOrder(model: model))
                orderId = result.data?.orderId ?? 0
                specialRequest = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

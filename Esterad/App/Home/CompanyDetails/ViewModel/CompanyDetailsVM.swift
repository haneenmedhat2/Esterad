//
//  CompanyDetailsVM.swift
//  Esterad
//
//  Created by Haneen on 20/11/2025.
//

import Foundation
import Combine

protocol CompanyDetailsVMProtocol {
    var companyDetailsPublisher: Published<BaseResponse<DelegateResponse>?>.Publisher { get }
    var privateRoomPublisher: Published<BaseResponse<SingleRoomResponse>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var products : [SubcategoryItem] { get }
    var reviewsList : [ReviewsModel] { get }
    var categories: [DelegateCategory] { get }
    var delegateModel : Delegate? { get }

    var delegateId : Int { get }
    var categoryId: Int { get }
        
    func getCompanyDetails()
    func createPrivateRoom()
}

final class CompanyDetailsVM: BaseViewModel,CompanyDetailsVMProtocol {
 
    @Published var companyDetails: BaseResponse<DelegateResponse>?
    @Published var privateRoom: BaseResponse<SingleRoomResponse>?
    
    var companyDetailsPublisher: Published<BaseResponse<DelegateResponse>?>.Publisher  { $companyDetails }
    var privateRoomPublisher: Published<BaseResponse<SingleRoomResponse>?>.Publisher { $privateRoom }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var products : [SubcategoryItem] = []
    var reviewsList : [ReviewsModel] = []
    var categories: [DelegateCategory] = []

    var delegateModel : Delegate?

    let delegateId : Int
    let categoryId: Int
    
    init(delegateId : Int ,categoryId: Int){
        self.delegateId = delegateId
        self.categoryId = categoryId
    }
   
    func getCompanyDetails(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getCompanyDetails(delegateId: delegateId))
                products = result.data?.delegate.products ?? []
                reviewsList = result.data?.delegate.reviews?.reversed() ?? []
                categories = result.data?.delegate.categories ?? []
                delegateModel = result.data?.delegate
                companyDetails = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    func createPrivateRoom() {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(
                    ChatEndPoints.createPrivateRoom(providerId: delegateId)
                )
                privateRoom = result
                isLoading = false
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

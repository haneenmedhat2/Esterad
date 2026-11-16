//
//  ReviewsVM.swift
//  Esterad
//
//  Created by Haneen on 25/11/2025.
//

import Foundation
import Combine

protocol ReviewsVMProtocol {
    var delegateReviewsPublisher: Published<BaseResponse<ReviewsModelResponse>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var reviewsList : [ReviewsModel] { get }
    var delegateId : Int { get }
    
    func getDelegateReviews()
    
}

final class ReviewsVM: BaseViewModel,ReviewsVMProtocol {
    
    @Published var delegateReviews: BaseResponse<ReviewsModelResponse>?
    
    var delegateReviewsPublisher: Published<BaseResponse<ReviewsModelResponse>?>.Publisher { $delegateReviews }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var delegateId : Int
    var reviewsList : [ReviewsModel] = []

    init(delegateId : Int){
        self.delegateId = delegateId
    }
    
    func getDelegateReviews(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getDelegateReviews(delegateId: delegateId))
                reviewsList = result.data?.reviews ?? []
                delegateReviews = result
                
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
}

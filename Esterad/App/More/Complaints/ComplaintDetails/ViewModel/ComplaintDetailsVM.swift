//
//  ComplaintDetailsVM.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import Foundation
import Combine

protocol ComplaintDetailsVMProtocol {
    
    var complaintDetailsPublisher: Published<BaseResponse<ComplaintsDetailsResponse>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var complaintId : Int { get }
    
    func complaintsDetailsRequest()
}

final class ComplaintDetailsVM: BaseViewModel,ComplaintDetailsVMProtocol {
    
    @Published var complaintDetails: BaseResponse<ComplaintsDetailsResponse>?

    var complaintDetailsPublisher: Published<BaseResponse<ComplaintsDetailsResponse>?>.Publisher { $complaintDetails }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var complaintId : Int
    init(complaintId : Int){
        self.complaintId = complaintId
    }

    func complaintsDetailsRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.complaintDetails(id: complaintId))
                complaintDetails = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

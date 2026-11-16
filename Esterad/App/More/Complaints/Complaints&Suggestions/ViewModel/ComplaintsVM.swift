//
//  ComplaintsVM.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import Foundation
import Combine

protocol ComplaintsVMProtocol {
    var complaintPublisher: Published<BaseResponse<ComplaintsResponse>?>.Publisher { get }
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var complaintsList : [ComplaintsModel] { get }
    
    func getComplaintsRequest()
    func addNewComplaintsRequest(model:AddComplaintsModel)
}

final class ComplaintsVM: BaseViewModel,ComplaintsVMProtocol {
    
    @Published var complaint: BaseResponse<ComplaintsResponse>?
    @Published var addNewComplaint: BaseResponse<AddComplaintsResponse>?

    var complaintPublisher: Published<BaseResponse<ComplaintsResponse>?>.Publisher { $complaint }
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { $addNewComplaint }
    
    var complaintsList : [ComplaintsModel] = []
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func getComplaintsRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.getComplaints())
                complaintsList = result.data?.tickets ?? []
                complaint = result
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
                getComplaintsRequest()
                addNewComplaint = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

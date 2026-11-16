//
//  GuestComplaintVM.swift
//  Esterad
//
//  Created by Haneen on 16/12/2025.
//


import Foundation
import Combine

protocol GuestComplaintVMProtocol {
    
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func addNewComplaintsRequest(model:AddComplaintsModel)
    
    func validateUserData(model:AddComplaintsModel) -> Bool
}

final class GuestComplaintVM: BaseViewModel,GuestComplaintVMProtocol {
    
    @Published var addNewComplaint: BaseResponse<AddComplaintsResponse>?
    @Published var validation: ValidationError?
    
    var addNewComplaintPublisher: Published<BaseResponse<AddComplaintsResponse>?>.Publisher { $addNewComplaint }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    
    func addNewComplaintsRequest(model:AddComplaintsModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.addNewComplaint(model: model))
                addNewComplaint = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateUserData(model:AddComplaintsModel) -> Bool {
        var validatedName = ""
        var validatedPhone = ""
        var validatedTitle = ""
        var validatedReason = ""

        switch ValidationService.validate(name: model.name) {
        case .success(let validName):
            validatedName = validName
            
        case .failure(let error):
            validation = error
            return false
        }
        
        switch ValidationService.validate(phone: model.phone){
        case .success(let validPhone):
            validatedPhone = validPhone
            
        case .failure(let error):
            validation = error
            return false
        }
        
        guard let title = model.subject, !title.trimWhiteSpace().isEmpty else{
            validation = ValidationError.emptyComplaintTitle
            return false
        }
        validatedTitle = title
        
        guard let reason = model.text , !reason.trimWhiteSpace().isEmpty else {
            validation = ValidationError.emptyComplaintReason
            return false
        }
        validatedReason = reason
        
        addNewComplaintsRequest(model:AddComplaintsModel(subject: validatedTitle, text: validatedReason, orderId: nil, name: validatedName, phone: validatedPhone))
        return true
    }
}

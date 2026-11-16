//
//  ChangePasswordVM.swift
//  Esterad
//
//  Created by Haneen on 04/11/2025.
//

import Foundation
import Combine

protocol ChangePasswordVMProtocol {
    
    var changePasswordPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func changePasswordRequest(model :ChangePasswordModel)
    func validateUserData(currentPassword : String? ,password : String? , passwordConfirmation : String?) -> Bool
}

final class ChangePasswordVM: BaseViewModel,ChangePasswordVMProtocol {
    
    @Published var changePassword: BaseResponse<String>?
    @Published var validation: ValidationError?

    var changePasswordPublisher: Published<BaseResponse<String>?>.Publisher { $changePassword }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }

    func changePasswordRequest(model :ChangePasswordModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.changePassword(model:model))
                isLoading = false
                changePassword = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateUserData(currentPassword : String? ,password : String? , passwordConfirmation : String?) -> Bool {
        
        var validatedCurrentPassword = ""
        var validatedPassword = ""
        var validatedConfirmPassword = ""

        switch ValidationService.validate(oldPassword : currentPassword){
        case .success(let validatePassword):
            validatedCurrentPassword = validatePassword
            
        case .failure(let error):
            validation = error
            return false
        }
        
        switch ValidationService.validate(newPassword: password){
        case .success(let validatePassword):
            validatedPassword = validatePassword
            
        case .failure(let error):
            validation = error
            return false
        }
        
        switch ValidationService.validate(newPassword: password, confirmPassword: passwordConfirmation){
        case .success(let validateConfirm):
            validatedConfirmPassword = validateConfirm
            
        case .failure(let error):
            validation = error
            return false
        }
        
        changePasswordRequest(model :ChangePasswordModel(currentPassword: validatedCurrentPassword, password: validatedPassword, passwordConfirmation: validatedConfirmPassword))
             return true
    }
}

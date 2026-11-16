//
//  ResetPasswordVM.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import Foundation

protocol ResetPasswordVMProtocol {
    var resetPasswordPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var phone : String { get }
    func resetPassword(model: ResetPasswordModel)
    func validateUserData( password : String? , confirmPassword : String?) -> Bool
}

final class ResetPasswordVM : BaseViewModel , ResetPasswordVMProtocol {
    @Published var resetPassword: BaseResponse<String>?
    @Published var validation: ValidationError?

    
    var resetPasswordPublisher: Published<BaseResponse<String>?>.Publisher { $resetPassword }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var phone : String 
    
    init(phone : String) {
        self.phone = phone
    }
    
    func resetPassword(model: ResetPasswordModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.resetPassword(model:ResetPasswordModel(phone: model.phone, password: model.password, passwordConfirmation: model.passwordConfirmation)))
                isLoading = false
                resetPassword = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateUserData( password : String? , confirmPassword : String?) -> Bool {
        var validatedPassword = ""
        var validatedConfirmPassword = ""
        
        switch ValidationService.validate(password: password){
        case .success(let validatePassword):
            validatedPassword = validatePassword
            
        case .failure(let error):
            validation = error
            return false
        }
        
        
        switch ValidationService.validate(newPassword: password, confirmPassword: confirmPassword){
        case .success(let validateConfirm):
            validatedConfirmPassword = validateConfirm
            
        case .failure(let error):
            validation = error
            return false
        }
        
        resetPassword(model: ResetPasswordModel(phone: phone, password: validatedPassword, passwordConfirmation: validatedConfirmPassword))
        
        return true
    }
}

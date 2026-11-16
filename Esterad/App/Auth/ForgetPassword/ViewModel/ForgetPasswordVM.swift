//
//  ForgetPasswordVM.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import Foundation
import Combine

protocol ForgetPasswordVMProtocol  {
    var forgetPasswordPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func forgetPassword(phone: String)
    func validatePhone(phone: String?) -> Bool

}

final class ForgetPasswordVM: BaseViewModel, ForgetPasswordVMProtocol {
    
    @Published var forgetPassword: BaseResponse<String>?
    @Published var validationError: ValidationError?
    
    var forgetPasswordPublisher: Published<BaseResponse<String>?>.Publisher { $forgetPassword }
    var validationPublisher: Published<ValidationError?>.Publisher { $validationError }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func forgetPassword(phone: String) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.forgetPassword(phone: phone))
                isLoading = false
                forgetPassword = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validatePhone(phone: String?) -> Bool {
        var validatedPhone = ""
        switch ValidationService.validate(phone: phone){
            case .success(let validPhone):
            validatedPhone = validPhone
            
        case .failure(let error):
            validationError = error
            return false
        }
        
        forgetPassword(phone: validatedPhone)
        return true
    }

}

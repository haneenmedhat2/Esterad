//
//  LoginVM.swift
//  Esterad
//
//  Created by Haneen on 15/10/2025.
//

import Foundation
import Combine

protocol LoginVMProtocol {
    
    var loginPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func loginRequest(model: LoginModel)
    func validateInputs(phone: String?, password: String?) -> Bool
}

final class LoginVM: BaseViewModel,LoginVMProtocol {
    
    @Published var login: BaseResponse<LoginResponse>?
    @Published var validationError: ValidationError?

    var loginPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { $login }
    var validationPublisher: Published<ValidationError?>.Publisher { $validationError }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func loginRequest(model: LoginModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.login(model: model))
                Session.user = result.data?.user
                Session.token = result.data?.token
                isLoading = false
                login = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateInputs(phone: String?, password: String?) -> Bool {
        var validatedPhone = ""
        var validatedPassword = ""

        switch ValidationService.validate(phone: phone){
            case .success(let validPhone):
            validatedPhone = validPhone
            
        case .failure(let error):
            validationError = error
            return false
        }

        switch ValidationService.validate(password: password){
        case .success(let validatePassword):
            validatedPassword = validatePassword
            
        case .failure(let error):
            validationError = error
            return false
        }
        
        loginRequest(model: LoginModel(phone: validatedPhone, password: validatedPassword))
          return true
      }
}

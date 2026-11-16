//
//  SignupVM.swift
//  Esterad
//
//  Created by Haneen on 18/10/2025.
//

import Foundation
import Combine

protocol SignupVMProtocol {
    var signupPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var isChecked : Bool { get set }
    var image : Data? { get set }
    
    func register(model: SignupModel)
    func validateUserData(username : String? ,phone : String? , email : String? , password : String? , confirmPassword : String?) -> Bool
}

final class SignupVM: BaseViewModel,SignupVMProtocol {
    
    @Published var signup: BaseResponse<LoginResponse>?
    @Published var validation: ValidationError?
    
    var signupPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { $signup }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var isChecked : Bool = false
    var image : Data?
    
    func register(model: SignupModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.signup(model: model, uploads: model.uploadData))
                isLoading = false
                signup = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateUserData(username : String? ,phone : String? , email : String? , password : String? , confirmPassword : String?) -> Bool  {
           var validatedName = ""
           var validatedPhone = ""
           var validatedPassword = ""
           var validatedConfirmPassword = ""
        
            switch ValidationService.validate(name: username) {
            case .success(let validName):
                validatedName = validName
                
            case .failure(let error):
                validation = error
                return false
            }
        
        switch ValidationService.validate(phone: phone){
            case .success(let validPhone):
            validatedPhone = validPhone
            
        case .failure(let error):
            validation = error
            return false
        }
        
        if let email = email , !email.trimWhiteSpace().isEmpty {
            if !email.isValidEmail() {
                validation = .wrongMail
                return false
            }
        }
        
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
        
                
        guard isChecked else {
            validation = .terms
            return false
        }
        
        register(model: SignupModel(email: email, name: validatedName, phone: validatedPhone, password: validatedPassword, confirmPassword: validatedConfirmPassword, avatar: image))
        
        return true
    }
    
}

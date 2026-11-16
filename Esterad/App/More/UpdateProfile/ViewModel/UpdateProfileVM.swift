//
//  UpdateProfileVM.swift
//  Esterad
//
//  Created by Haneen on 03/11/2025.
//

import Foundation
import Combine

protocol UpdateProfileVMProtocol {
    
    var updateProfilePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var image : Data? { get set }

    func updateProfileRequest(model: UpdateProfileModel)
    func validateUserData(username : String? , email : String?) -> Bool
}

final class UpdateProfileVM: BaseViewModel,UpdateProfileVMProtocol {
    @Published var updateProfile: BaseResponse<ProfileResponseModel>?
    @Published var validation: ValidationError?

    var updateProfilePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { $updateProfile }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var image : Data?

    func updateProfileRequest(model: UpdateProfileModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.updateProfile( model: model, uploads: model.uploadData))
                Session.user = result.data?.user
                updateProfile = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateUserData(username : String? , email : String?) -> Bool {
        var validatedName = ""
        var validateEmail : String? = ""

        switch ValidationService.validate(name: username) {
        case .success(let validName):
            validatedName = validName
            
        case .failure(let error):
            validation = error
            return false
        }
        
        if let email = email , !email.trimWhiteSpace().isEmpty {
            if !email.isValidEmail() {
                validation = .wrongMail
                return false
            }
            validateEmail = email
        }
        updateProfileRequest(model: UpdateProfileModel(editAvatar: image, name: validatedName, email: validateEmail))
        return true
    }
}

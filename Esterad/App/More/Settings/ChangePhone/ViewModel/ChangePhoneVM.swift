//
//  ChangePhoneVM.swift
//  Esterad
//
//  Created by Haneen on 04/11/2025.
//

import Foundation
protocol ChangePhoneVMProtocol {
    
    var changePhonePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func changePhoneRequest(phone :String)
    func validatePhone(phone: String?) -> Bool
}

final class ChangePhoneVM: BaseViewModel,ChangePhoneVMProtocol {
    
    @Published var changePhone: BaseResponse<ProfileResponseModel>?
    @Published var validation: ValidationError?

    var changePhonePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { $changePhone }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }

    func changePhoneRequest(phone :String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.changePhone( phone: phone ))
                isLoading = false
                changePhone = result
                
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
            validation = error
            return false
        }
        changePhoneRequest(phone :validatedPhone)
        return true
    }
}

//
//  ContactUsVM.swift
//  Esterad
//
//  Created by Haneen on 09/11/2025.
//

import Foundation
import Combine

protocol ContactUsVMProtocol {

    var contactUsPublisher: Published<BaseResponse<String>?>.Publisher { get }
    var socialPublisher: Published<BaseResponse<SocialResponse>?>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
        
    var socialList : [Social] { get }
    
    func socialRequest()
    func validateInputs(model: ContactUsModel) -> Bool
}

final class ContactUsVM: BaseViewModel,ContactUsVMProtocol {
    
    @Published var contactUs: BaseResponse<String>?
    @Published var social: BaseResponse<SocialResponse>?
    @Published var validationError: ValidationError?

    var contactUsPublisher: Published<BaseResponse<String>?>.Publisher { $contactUs }
    var socialPublisher: Published<BaseResponse<SocialResponse>?>.Publisher { $social }
    var validationPublisher: Published<ValidationError?>.Publisher { $validationError }
    
    var socialList : [Social] = []

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    private func contactUsWithToken(model: ContactUsModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(
                    MoreEndpoints.contactUs(
                        token: UserDefaults.accessToken ?? "",
                        model: model
                    )
                )
                contactUs = result
                isLoading = false
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    private func contactUsWithoutToken(model: ContactUsModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(
                    MoreEndpoints.contactUs(model: model)
                )
                contactUs = result
                isLoading = false
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    
    func socialRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.socials())
                social = result
                socialList = result.data?.socials ?? []
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func validateInputs(model: ContactUsModel) -> Bool {

        switch UserMode.current {
        case .authenticated:
            return validateAuthenticatedUser(model: model)

        case .guest:
            return validateGuestUser(model: model)
        }
    }
    
    private func validateAuthenticatedUser(model: ContactUsModel) -> Bool {

        guard let title = model.title, !title.trimWhiteSpace().isEmpty else {
            validationError = .emptyTitle
            return false
        }

        guard let message = model.message, !message.trimWhiteSpace().isEmpty else {
            validationError = .emptyMessage
            return false
        }

        let requestModel = ContactUsModel(
            name: nil,
            phone: nil,
            message: message,
            title: title
        )

        contactUsWithToken(model: requestModel)
        return true
    }
    
    private func validateGuestUser(model: ContactUsModel) -> Bool {

        let validatedName: String
        let validatedPhone: String

        switch ValidationService.validate(name: model.name) {
        case .success(let name):
            validatedName = name
        case .failure(let error):
            validationError = error
            return false
        }

        switch ValidationService.validate(phone: model.phone) {
        case .success(let phone):
            validatedPhone = phone
        case .failure(let error):
            validationError = error
            return false
        }

        guard let title = model.title, !title.trimWhiteSpace().isEmpty else {
            validationError = .emptyTitle
            return false
        }

        guard let message = model.message, !message.trimWhiteSpace().isEmpty else {
            validationError = .emptyMessage
            return false
        }

        let requestModel = ContactUsModel(
            name: validatedName,
            phone: validatedPhone,
            message: message,
            title: title
        )

        contactUsWithoutToken(model: requestModel)
        return true
    }
}

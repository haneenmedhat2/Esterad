//
//  VerificationVM.swift
//  Esterad
//
//  Created by Haneen on 19/10/2025.
//

import Foundation
import Combine

protocol VerificationVMProtocol {
    var verificationPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { get }
    var resendCodePublisher: Published<BaseResponse<String>?>.Publisher { get }
    var resendCurrentPhoneCodePublisher: Published<BaseResponse<String>?>.Publisher { get }
    var currentPhoneActivationPublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { get }
    var resendChangePhoneCodePublisher: Published<BaseResponse<String>?>.Publisher { get }
    var changePhoneActivationPublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { get }
    var updateLocationPublisher: PassthroughSubject<BaseResponse<User>,Never> { get }
    var remainingTimePublisher: Published<Int>.Publisher { get }
    var isResendEnabledPublisher: Published<Bool>.Publisher { get }
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var flow : VerificationFlow { get }
    var phoneNumber : String { get }
    
    func startCountdown()
    func handleResendCode()
    func validateOTP(otp : String?) -> Bool
    func verificationRequest(model: VerificationModel)
    func resendCodeRequest(phone: String)
    func resendCurrentPhoneCodeRequest()
    func currentPhoneActivationRequest(code: String)
    func resendChangePhoneCodeRequest()
    func changePhoneActivation(code: String)
    func updateLocation(model : UpdateLocationModel)
}

final class VerificationVM : BaseViewModel , VerificationVMProtocol {
    @Published var verification: BaseResponse<LoginResponse>?
    @Published var resendCode: BaseResponse<String>?
    @Published var resendCurrentPhoneCode: BaseResponse<String>?
    @Published var currentPhoneActivation: BaseResponse<ProfileResponseModel>?
    @Published var resendChangePhoneCode: BaseResponse<String>?
    @Published var changePhoneActivation: BaseResponse<ProfileResponseModel>?
    @Published var validation: ValidationError?

    @Published private(set) var remainingTime: Int = 0
    @Published private(set) var isResendEnabled: Bool = true
    
    var verificationPublisher: Published<BaseResponse<LoginResponse>?>.Publisher { $verification }
    var resendCodePublisher: Published<BaseResponse<String>?>.Publisher { $resendCode }
    var resendCurrentPhoneCodePublisher: Published<BaseResponse<String>?>.Publisher { $resendCurrentPhoneCode }
    var currentPhoneActivationPublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { $currentPhoneActivation }
    var resendChangePhoneCodePublisher: Published<BaseResponse<String>?>.Publisher { $resendChangePhoneCode }
    var changePhoneActivationPublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { $changePhoneActivation }
    var updateLocationPublisher: PassthroughSubject<BaseResponse<User>,Never> = .init()
    
    var remainingTimePublisher: Published<Int>.Publisher {$remainingTime}
    var isResendEnabledPublisher: Published<Bool>.Publisher { $isResendEnabled }
    var validationPublisher: Published<ValidationError?>.Publisher { $validation }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var flow : VerificationFlow
    var phoneNumber : String
    
    private var timer: Timer?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(flow : VerificationFlow,phoneNumber : String){
        self.flow = flow
        self.phoneNumber = phoneNumber
    }
    
    func startCountdown() {
        timer?.invalidate()
        isResendEnabled = false
        remainingTime =  600
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingTime -= 1
            
            if self.remainingTime <= 0 {
                stopCountdown()
            }
        }
    }
    
    func stopCountdown() {
        timer?.invalidate()
        timer = nil
        isResendEnabled = true
    }
    
    func handleResendCode(){
        if isResendEnabled {
            switch flow {
            case .signup , .changePassword:
                resendCodeRequest(phone: phoneNumber)
            case .activateCurrentPhone:
               resendCurrentPhoneCodeRequest()
            case .activateNewPhone:
               resendChangePhoneCodeRequest()
            }
        }
    }
    
    func validateOTP(otp : String?) -> Bool {
        var validatedOTP = ""

        switch ValidationService.validate(verificationCode: otp){
        case .success(let OTP):
            validatedOTP = OTP
            
        case .failure(let error):
            validation = error
            return false
        }
        switch flow {
        case .signup,.changePassword:
            verificationRequest(model: VerificationModel(code: validatedOTP, phone: phoneNumber))
        case .activateCurrentPhone:
            currentPhoneActivationRequest(code: validatedOTP)
        case .activateNewPhone:
          changePhoneActivation(code: validatedOTP)
        }
        return true
    }
    
    func verificationRequest(model: VerificationModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.verification(model: VerificationModel(code: model.code, phone: model.phone)))
                isLoading = false
                verification = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func resendCodeRequest(phone: String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(AuthEndpoints.resendCode(phone: phone))
                isLoading = false
                resendCode = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func resendCurrentPhoneCodeRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.resendCurrentPhoneCode())
                isLoading = false
                resendCurrentPhoneCode = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func currentPhoneActivationRequest(code: String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.currentPhoneActivation(code: code))
                isLoading = false
                currentPhoneActivation = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func resendChangePhoneCodeRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.resendChangePhoneCode())
                isLoading = false
                resendChangePhoneCode = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func changePhoneActivation(code: String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.changePhoneActivation(code: code))
                isLoading = false
                changePhoneActivation = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func updateLocation(model : UpdateLocationModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.updateLocation(model: model))
                isLoading = false
                updateLocationPublisher.send(result)
                Session.user = result.data
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

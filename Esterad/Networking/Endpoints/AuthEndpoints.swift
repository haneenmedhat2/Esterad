//
//  AuthEndpoints.swift
//  App
//
//  Created by MGAbouarab on 22/12/2023.
//

import Foundation

struct AuthEndpoints {
    private init() {}
}

extension AuthEndpoints {
    
    static func login(model : LoginModel) -> Endpoint<BaseResponse<LoginResponse>>{
        return .init(
            method: .post,
            path: "login",
            body: [
                "phone": model.phone,
                "password": model.password,
                "device_id": UserDefaults.pushNotificationToken,
                "device_type": "ios",
                "type": "user"
            ]
        )
    }
    
    static func signup( model: SignupModel, uploads: [UploadData]) -> Endpoint<BaseResponse<LoginResponse>>{
        return .init(
            method: .post,
            path: "register",
            body:[
                "email" : model.email,
                "name" : model.name,
                "phone" : model.phone,
                "password" : model.password,
                "password_confirmation" : model.confirmPassword,
                "device_id": UserDefaults.pushNotificationToken,
                "device_type": "ios"
            ],
            uploads: uploads
        )
    }
    
    static func verification(model : VerificationModel) -> Endpoint<BaseResponse<LoginResponse>> {
        return .init(
            method: .post,
            path: "account/activation",
            body: [
                "code": model.code,
                "phone": model.phone,
                "type": "user"
            ]
        )
    }
    
    static func resendCode(phone: String) -> Endpoint<BaseResponse<String>> {
        return .init(
            method: .post,
            path: "code/resend",
            body: [
                "phone": phone,
                "type": "user"
            ]
        )
    }
    
    static func forgetPassword(phone: String) -> Endpoint<BaseResponse<String>> {
        return .init(
            method: .post,
            path: "password/forget",
            body: [
                "phone": phone,
                "type": "user"
            ]
        )
    }
    
    static func resetPassword(model: ResetPasswordModel) -> Endpoint<BaseResponse<String>> {
        return .init(
            method: .post,
            path: "password/reset",
            body: [
                "phone": model.phone,
                "type": "user",
                "password" : model.password,
                "password_confirmation" : model.passwordConfirmation
            ]
        )
    }
}

//
//  MoreEndPoints.swift
//  Waraqa
//
//  Created by Haneen on 21/08/2025.
//

import Foundation

struct MoreEndpoints {
    private init() {}
}

extension MoreEndpoints {
    
    static func profile() -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .get,
            path: "profile/show",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func updateProfile(model:UpdateProfileModel, uploads: [UploadData]) -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .post,
            path: "profile/update",
            body: [
                "name": model.name,
                "email": model.email
            ],
            headerType: .authorized(token: Session.token ?? ""),
            uploads: uploads
        )
    }
    
    static func sendCurrentPhoneCode() -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .post,
            path: "profile/send-current-phone-code",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func resendCurrentPhoneCode() -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "profile/resend-current-phone-code",
            headerType: .authorized(token: Session.token ?? ""),
        )
    }
    
    static func currentPhoneActivation(code:String) -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .post,
            path: "profile/current-phone-activation",
            body: [
                "code": code
            ],
            headerType: .authorized(token: Session.token ?? ""),
        )
    }
    
    static func changePhone(phone:String) -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .post,
            path: "profile/change-phone",
            body: [
                "phone": phone
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func changePhoneActivation(code : String) -> Endpoint<BaseResponse<ProfileResponseModel>>{
        return .init(
            method: .post,
            path: "profile/changed-phone-activation",
            body: [
                "code": code
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func resendChangePhoneCode() -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "profile/resend-changed-phone-code",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func changePassword(model:ChangePasswordModel ) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "profile/change-password",
            body: [
                "current_password": model.currentPassword,
                "password" : model.password,
                "password_confirmation" : model.passwordConfirmation
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func switchNotification() -> Endpoint<BaseResponse<SwitchNotification>>{
        return .init(
            method: .patch,
            path: "switch-notification",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func changeLanguage(lang: String) -> Endpoint<BaseResponse<User>>{
        return .init(
            method: .post,
            path: "profile/change-lang",
            body: [
                "lang": lang
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func deleteAccount(deviceId: String) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "profile/delete",
            body: [
                "device_id": deviceId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func showWallet() -> Endpoint<BaseResponse<WalletResponse>>{
        return .init(
            method: .get,
            path: "wallet",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func chargeWallet( amount: Double) -> Endpoint<BaseResponse<ChargeWalletResponse>>{
        return .init(
            method: .post,
            path: "charge-wallet",
            body: ["amount" : amount],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func aboutUs() -> Endpoint<BaseResponse<AboutUsResponse>>{
        return .init(
            method: .get,
            path: "about-us"
        )
    }
    
    static func termsAndConditions() -> Endpoint<BaseResponse<TermsAndConditionsResponse>>{
        return .init(
            method: .get,
            path: "terms"
        )
    }
    
    static func getComplaints() -> Endpoint<BaseResponse<ComplaintsResponse>>{
        return .init(
            method: .get,
            path: "get-tickets",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getFaq() -> Endpoint<BaseResponse<FAQResponse>>{
        return .init(
            method: .get,
            path: "fqs"
        )
    }
    
    static func complaintDetails(id:Int) -> Endpoint<BaseResponse<ComplaintsDetailsResponse>>{
        return .init(
            method: .get,
            path: "single-ticket",
            queries: [
                "ticket_id" : id
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func addNewComplaint(token:String,model: AddComplaintsModel) -> Endpoint<BaseResponse<AddComplaintsResponse>>{
        return .init(
            method: .post,
            path: "create-ticket",
            body: [
                "subject": model.subject,
                "text" : model.text,
                "order_id": model.orderId,
                "name" : model.name,
                "phone" : model.phone
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func addNewComplaint(model: AddComplaintsModel) -> Endpoint<BaseResponse<AddComplaintsResponse>>{
        return .init(
            method: .post,
            path: "create-ticket",
            body: [
                "subject": model.subject,
                "text" : model.text,
                "order_id": model.orderId,
                "name" : model.name,
                "phone" : model.phone
            ],
        )
    }
    
    static func contactUs(token:String,model: ContactUsModel) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "contact-us",
            body: [
                "name" : model.name,
                "phone" : model.phone,
                "title" : model.title,
                "message" : model.message
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }

    static func contactUs(model: ContactUsModel) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "contact-us",
            body: [
                "name" : model.name,
                "phone" : model.phone,
                "title" : model.title,
                "message" : model.message
            ]
        )
    }
    static func socials() -> Endpoint<BaseResponse<SocialResponse>>{
        return .init(
            method: .get,
            path: "socials"
        )
    }

    static func signout(deviceId: String) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "logout",
            body: [
                "device_id": deviceId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
}

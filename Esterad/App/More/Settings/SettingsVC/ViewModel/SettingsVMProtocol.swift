//
//  SettingsVMProtocol.swift
//  Esterad
//
//  Created by Haneen on 03/11/2025.
//

import Foundation
import Combine

protocol SettingsVMProtocol {
    
    var changeLanguagePublisher: Published<BaseResponse<User>?>.Publisher { get }
    var sendCurrentPhoneCodePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { get }
    var switchNotificationPublisher: Published<BaseResponse<SwitchNotification>?>.Publisher { get }
    var deleteAccountPublisher: Published<BaseResponse<String>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var settingsItems : [MoreMenuItem] { get  }
    var isGuest: Bool { get }
    
    func changeLanguage(lang: String)
    func sendCurrentPhoneCodeRequest()
    func switchNotificationRequest()
    func deleteAccountRequest()
}

final class SettingsVM: BaseViewModel,SettingsVMProtocol {
    
    @Published var changeLanguage: BaseResponse<User>?
    @Published var sendCurrentPhoneCode: BaseResponse<ProfileResponseModel>?
    @Published var switchNotification: BaseResponse<SwitchNotification>?
    @Published var deleteAccount: BaseResponse<String>?

    
    var changeLanguagePublisher: Published<BaseResponse<User>?>.Publisher { $changeLanguage }
    var sendCurrentPhoneCodePublisher: Published<BaseResponse<ProfileResponseModel>?>.Publisher { $sendCurrentPhoneCode }
    var switchNotificationPublisher: Published<BaseResponse<SwitchNotification>?>.Publisher { $switchNotification }
    var deleteAccountPublisher: Published<BaseResponse<String>?>.Publisher { $deleteAccount }

    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var settingsItems : [MoreMenuItem] {
        return MoreMenuItem.settingsItems(for: UserMode.current)
    }
    
    var isGuest: Bool {
        return UserDefaults.guest
    }
    
    func changeLanguage(lang: String){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.changeLanguage( lang: lang))
                isLoading = false
                changeLanguage = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func sendCurrentPhoneCodeRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.sendCurrentPhoneCode())
                isLoading = false
                sendCurrentPhoneCode = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func switchNotificationRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.switchNotification())
                isLoading = false
                switchNotification = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func deleteAccountRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.deleteAccount( deviceId: UserDefaults.pushNotificationToken ?? "" ))
                isLoading = false
                deleteAccount = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}


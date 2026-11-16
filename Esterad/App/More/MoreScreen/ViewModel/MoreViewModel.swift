//
//  MoreViewModel.swift
//  Esterad
//
//  Created by Haneen on 29/10/2025.
//

import Foundation
import Combine

protocol MoreVMProtocol {
    var signout : PassthroughSubject<BaseResponse<String>,Never> { get }
    var profile : PassthroughSubject<User,Never> { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var menuItems: [MoreMenuItem] { get }
    
    func signoutRequest()
    func profileRequest()
}


final class MoreVM: BaseViewModel,MoreVMProtocol {
    var signout: PassthroughSubject<BaseResponse<String>, Never> = .init()
    var profile: PassthroughSubject<User, Never> = .init()

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    
    var menuItems: [MoreMenuItem] {
        return MoreMenuItem.moreItems(for: UserMode.current)
    }
    
    var moreList : [MoreMenuItem] = []
    
    func profileRequest() {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.profile(), progress: nil)
                guard let user = result.data?.user else { return }
                Session.user = user
                profile.send(user)
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func signoutRequest() {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.signout( deviceId:  UserDefaults.pushNotificationToken ?? "" ))
                signout.send(result)
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

//
//  ChooseLocationVM.swift
//  Esterad
//
//  Created by Haneen on 12/11/2025.
//

import Foundation
import Combine

protocol ChooseLocationVMProtocol {
    
    var updateLocationPublisher: PassthroughSubject<BaseResponse<User>,Never> { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func updateLocation(model : UpdateLocationModel)
}

final class ChooseLocationVM : BaseViewModel , ChooseLocationVMProtocol {
    
    var updateLocationPublisher: PassthroughSubject<BaseResponse<User>,Never> = .init()
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func updateLocation(model : UpdateLocationModel){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.updateLocation(model: model))
                isLoading = false
                updateLocationPublisher.send(result)
                UserDefaults.user = result.data
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

//
//  WalletPopupVM.swift
//  Esterad
//
//  Created by Haneen on 06/12/2025.
//

import Foundation
import Combine

protocol WalletPopupVMProtocol {
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var validationPublisher: Published<ValidationError?>.Publisher { get }
    var validatedAmount : Double { get }
    
    func validateWalletAmount(amount : String?) -> Bool
}

final class WalletPopupVM: BaseViewModel,WalletPopupVMProtocol {
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    @Published var validationError: ValidationError?

    var validationPublisher: Published<ValidationError?>.Publisher { $validationError }
    var validatedAmount : Double = 0.0

    func validateWalletAmount(amount : String?) -> Bool {

        switch ValidationService.validateWalletRecharge(amount: amount){
            case .success(let validAmount):
            validatedAmount = validAmount
            
        case .failure(let error):
            validationError = error
            return false
        }
          return true
      }
}

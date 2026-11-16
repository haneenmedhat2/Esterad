//
//  WalletVM.swift
//  Esterad
//
//  Created by Haneen on 05/11/2025.
//

import Foundation
import Combine

protocol WalletVMProtocol {
    var showWalletPublisher: Published<BaseResponse<WalletResponse>?>.Publisher { get }
    var chargeWalletPublisher: Published<BaseResponse<ChargeWalletResponse>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func showWalletRequest()
    func chargeWalletRequest(amount : Double)
}

final class WalletVM: BaseViewModel,WalletVMProtocol {
    
    @Published var showWallet: BaseResponse<WalletResponse>?
    @Published var chargeWallet: BaseResponse<ChargeWalletResponse>?

    var showWalletPublisher: Published<BaseResponse<WalletResponse>?>.Publisher { $showWallet }
    var chargeWalletPublisher: Published<BaseResponse<ChargeWalletResponse>?>.Publisher { $chargeWallet }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func showWalletRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.showWallet())
                showWallet = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func chargeWalletRequest(amount : Double){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.chargeWallet(amount: amount))
                chargeWallet = result
                showWalletRequest()
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

}

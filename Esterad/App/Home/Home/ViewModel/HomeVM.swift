//
//  HomeVM.swift
//  Esterad
//
//  Created by Haneen on 11/11/2025.
//

import Foundation
import Combine

protocol HomeVMProtocol {
    var homePublisher: Published<BaseResponse<HomeResponse>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var categoryList : [Category] { get }

    func gethomeData()
}

final class HomeVM: BaseViewModel,HomeVMProtocol {
 
    @Published var home: BaseResponse<HomeResponse>?

    var homePublisher: Published<BaseResponse<HomeResponse>?>.Publisher { $home }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var categoryList : [Category] = []
   
    func gethomeData(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getHomeData())
                categoryList = result.data?.categories ?? []
                home = result

                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

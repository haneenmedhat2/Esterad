//
//  RoomsVMProtocol.swift
//  Esterad
//
//  Created by Haneen on 07/12/2025.
//


import Foundation
import Combine

protocol RoomsVMProtocol {
    
    var chatRoomsPublisher: Published<BaseResponse<RoomsResponse>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var roomsList : [RoomModel] { get }
    
    func getRooms()
}

final class RoomsVM: BaseViewModel,RoomsVMProtocol {
    
    @Published var chatRooms: BaseResponse<RoomsResponse>?

    var chatRoomsPublisher: Published<BaseResponse<RoomsResponse>?>.Publisher { $chatRooms }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var roomsList : [RoomModel] = []

    func getRooms(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(ChatEndPoints.getRooms())
                isLoading = false
                roomsList = result.data?.rooms ?? []
                chatRooms = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
}

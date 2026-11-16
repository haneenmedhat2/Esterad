//
//  ChatVM.swift
//  Esterad
//
//  Created by Haneen on 07/12/2025.
//


import Foundation
import Combine

protocol ChatVMProtocol {
    
    var singleRoomPublisher: Published<BaseResponse<SingleRoomResponse>?>.Publisher { get }
    var uploadFilePublisher: Published<BaseResponse<UploadFileResponse>?>.Publisher { get }
    var messageText : CurrentValueSubject<String,Never> { get }
    var isSendEnabled : AnyPublisher<Bool,Never> { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var messagesList : [ChatMessage] { get set }
    var currentPage : Int { get }
    var isLastPage: Bool { get }
    var roomId : Int { get }
    var totalPage: Int {get}

    var senderName : String { get }
    func loadRoom()
    func getSingleRoom()
    func uploadFileRequest(model : UploadFileModel)
    func resetData()
    func loadMoreData()

}

final class ChatVM: BaseViewModel,ChatVMProtocol {
    
    @Published var singleRoom: BaseResponse<SingleRoomResponse>?
    @Published var uploadFile: BaseResponse<UploadFileResponse>?

    var singleRoomPublisher: Published<BaseResponse<SingleRoomResponse>?>.Publisher { $singleRoom }
    var uploadFilePublisher: Published<BaseResponse<UploadFileResponse>?>.Publisher { $uploadFile }
    var messageText : CurrentValueSubject<String,Never> = .init("")
    var isSendEnabled : AnyPublisher<Bool,Never> {
        messageText
            .map {!$0.trimWhiteSpace().isEmpty}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var messagesList : [ChatMessage] = []
    var currentPage:Int = 1
    var isLastPage: Bool = false
    var roomId : Int
    var senderName : String
    var totalPage: Int = 1
    private let providerId: Int?
    private var shouldUseInitialResponse = false

    init(roomId : Int ,senderName : String ){
        self.roomId = roomId
        self.senderName = senderName
        self.providerId = nil
    }

    init(
        providerId: Int,
        senderName: String,
        initialResponse: BaseResponse<SingleRoomResponse>
    ) {
        self.providerId = providerId
        self.senderName = senderName
        self.roomId = initialResponse.data?.room.id ?? 0
        self.singleRoom = initialResponse
        self.shouldUseInitialResponse = true
        super.init()
        apply(initialResponse)
    }

    func loadRoom() {
        if shouldUseInitialResponse {
            shouldUseInitialResponse = false
            return
        }
        if let providerId {
            createPrivateRoom(providerId: providerId)
        } else {
            getSingleRoom()
        }
    }
    
    func getSingleRoom(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(ChatEndPoints.getSingleRoom(page: currentPage, roomId : roomId))
                
                apply(result)
//                isLastPage = result.data?.room.pagination.isLastPage ?? false
//                
//                if !isLastPage {
//                    currentPage += 1
//                }
                isLoading = false
                singleRoom = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    private func createPrivateRoom(providerId: Int) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(
                    ChatEndPoints.createPrivateRoom(providerId: providerId)
                )
                roomId = result.data?.room.id ?? roomId
                apply(result)
                isLoading = false
                singleRoom = result
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    private func apply(_ result: BaseResponse<SingleRoomResponse>) {
        let messageList = result.data?.room.messages ?? []
        if currentPage == 1 {
            messagesList = messageList
        } else {
            messagesList.append(contentsOf: messageList)
        }
        currentPage = result.data?.room.pagination.currentPage ?? 1
        totalPage = providerId == nil ? (result.data?.room.pagination.totalPages ?? 1) : 1
    }
    
    func uploadFileRequest(model : UploadFileModel) {
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(ChatEndPoints.uploadFile(model: model))
                isLoading = false
                uploadFile = result
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func resetData() {
        currentPage = 1
        isLastPage = false
    }
    
    func loadMoreData(){
        self.currentPage += 1
        self.loadRoom()
    }
}

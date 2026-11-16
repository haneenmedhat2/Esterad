//
//  ChatModel.swift
//  Esterad
//
//  Created by Haneen on 07/12/2025.
//ص

import Foundation

struct SingleRoomResponse : Codable {
    let room : SingleRoomModel
}

struct SingleRoomModel : Codable {
    let id : Int?
    let date : String?
    let time : String?
    let status : String?
    let messages : [ChatMessage]?
    let pagination : Pagination
    let userOne: ChatParticipant?
    let userTwo: ChatParticipant?

    enum CodingKeys: String, CodingKey {
        case id, date, time, status, messages, pagination
        case userOne = "userone"
        case userTwo = "usertwo"
    }
    
    func getSenderData() -> ChatSocketConnection.SenderData {
        return .init(type: .client, id: "\(UserDefaults.user?.id ?? 0)" , senderName: UserDefaults.user?.name ?? "", avatar: UserDefaults.user?.avatar ?? "")
    }
    
    func getReceiverData() -> ChatSocketConnection.ReceiverData {
        let type: ChatSocketConnection.UserType = .provider

        let providerId = [userOne, userTwo]
            .compactMap { $0 }
            .first(where: { $0.userType == type.rawValue })?
            .id
            ?? messages?.first(where: { $0.sentByMe == false })?.senderId
            ?? 0
        let id = "\(providerId)"
        return .init(id: id, type: type)
    }
}

struct ChatParticipant: Codable {
    let id: Int
    let name: String?
    let avatarPath: String?
    let userType: String?
}

struct ChatMessage : Codable {
    let id : Int?
    let content : String?
    let duration : Int?
    let avatar : String?
    let type : String?
    let date : String?
    let time : String?
    let sentByMe : Bool?
    let senderId : Int?
    let status : String?
    
    var messageType : MessageType {
        if type == "text" {
            return .text
        } else {
            return .image
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, duration, avatar, type, date, time, status
        case sentByMe = "sent_by_me"
        case senderId = "sender_id"
    }
}

enum MessageType {
    case text
    case image
}


struct UploadFileModel : Codable {
    let file : Data?
    let type : String
    
    var uploadData: [UploadData] {
        var files = [UploadData]()
        if let avatarData = file {
            files.append(UploadData(
                key: "file",
                data: avatarData,
                mimeType: .jpeg,
                fileName: "\(Date().timeIntervalSince1970).jpeg"
            ))
        }
        return files
    }
}

struct UploadFileResponse : Codable {
    let name : String?
    let url : String?
    let duration : String?
}

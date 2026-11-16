//
//  ChatEndPoints.swift
//  Esterad
//
//  Created by Haneen on 07/12/2025.
//

struct ChatEndPoints {
    private init() {}
}

extension ChatEndPoints {

    static func createPrivateRoom(providerId: Int) -> Endpoint<BaseResponse<SingleRoomResponse>> {
        return .init(
            method: .post,
            path: "create-private-room",
            body: [
                "provider_id": providerId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getRooms() -> Endpoint<BaseResponse<RoomsResponse>>{
        return .init(
            method: .get,
            path: "rooms",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func getSingleRoom(page : Int ,roomId : Int) -> Endpoint<BaseResponse<SingleRoomResponse>>{
        return .init(
            method: .get,
            path: "single-room",
            queries: [
                "room_id" : roomId,
                "page": page
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func uploadFile(model : UploadFileModel) -> Endpoint<BaseResponse<UploadFileResponse>>{
        return .init(
            method: .post,
            path: "upload-file",
            body: [
                "type" : model.type
            ],
            headerType: .authorized(token: Session.token ?? ""),
            uploads: model.uploadData
        )
    }
}

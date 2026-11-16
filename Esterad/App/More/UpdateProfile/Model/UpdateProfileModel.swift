//
//  UpdateProfileModel.swift
//  Esterad
//
//  Created by Haneen on 03/11/2025.
//

import Foundation

struct UpdateProfileModel: Codable {
    var editAvatar : Data?
    var name : String?
    var email : String?
    
    var uploadData: [UploadData] {
        var files = [UploadData]()
        if let avatarData = editAvatar {
            files.append(UploadData(
                key: "edit_avatar",
                data: avatarData,
                mimeType: .jpeg,
                fileName: "\(Date().timeIntervalSince1970).jpeg"
            ))
        }
        return files
    }
    
    enum CodingKeys: String, CodingKey {
        case editAvatar = "edit_avatar"
        case name
        case email
    }
}

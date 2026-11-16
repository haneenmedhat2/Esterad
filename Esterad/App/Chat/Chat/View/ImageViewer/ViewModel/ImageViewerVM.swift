//
//  ImageViewerVM.swift
//  Esterad
//
//  Created by Haneen on 10/12/2025.
//

import Foundation
import Combine

protocol ImageViewerVMProtocol {
    
    var imgURL : String { get }
}

final class ImageViewerVM: BaseViewModel,ImageViewerVMProtocol {
    
    var imgURL : String
    
    init(imgURL : String){
        self.imgURL = imgURL
    }
}

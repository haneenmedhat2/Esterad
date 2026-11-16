//
//  ProductDetailsVMProtocol.swift
//  Esterad
//
//  Created by Haneen on 19/11/2025.
//

import Foundation
import Combine

protocol ProductDetailsVMProtocol {
    var productDetailsPublisher: Published<BaseResponse<ProductResponse>?>.Publisher { get }
    var productAvailabilityPublisher: Published<BaseResponse<String>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var productImageList : [ProductImage] { get }
    
    var showCarDetailsView: Bool { get set }
    var showFurnitureDetailsView: Bool { get set }
    var selectedIndex : IndexPath { get set }
    var downPaymentPrice : String {get set }

    var productId : Int { get }
    
    func getProductDetails()
    func askProductAvailability()
}

final class ProductDetailsVM: BaseViewModel,ProductDetailsVMProtocol {
    
 
    @Published var productDetails: BaseResponse<ProductResponse>?
    @Published var productAvailability: BaseResponse<String>?

    var productDetailsPublisher: Published<BaseResponse<ProductResponse>?>.Publisher { $productDetails }
    var productAvailabilityPublisher: Published<BaseResponse<String>?>.Publisher { $productAvailability }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var productId : Int
    
    var productImageList : [ProductImage] = []
    var selectedIndex = IndexPath(item: 0, section: 0)
    var downPaymentPrice : String = "0"


    var showCarDetailsView: Bool = true
    var showFurnitureDetailsView: Bool = false
  
    init(productId : Int){
        self.productId = productId
    }
   
    func getProductDetails(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getProductDetails(productId: productId))
                productImageList = result.data?.product?.images ?? []
                downPaymentPrice = result.data?.product?.downPaymentPrice ?? ""
                productDetails = result
                
                let categoryId = result.data?.product?.categoryId ?? 1
                
                if  categoryId == 1  || categoryId == 2 {
                    showCarDetailsView = true
                    showFurnitureDetailsView = false
                } else {
                    showCarDetailsView = false
                    showFurnitureDetailsView = true
                }
                
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func askProductAvailability(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.askProductAvailability(productId: productId))
               
                productAvailability = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

}

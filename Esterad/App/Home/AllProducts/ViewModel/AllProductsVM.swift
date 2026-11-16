//
//  AllProductsVM.swift
//  Esterad
//
//  Created by Haneen on 24/11/2025.
//

import Foundation
import Combine

protocol AllProductsVMProtocol {

    var delegateProductsPublisher: Published<BaseResponse<DelegateProductsResponse>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var searchTextSubject : PassthroughSubject<String, Never> { get }
    
    var delegateId : Int { get }
    var delegateCategories : [DelegateCategory] { get }

    var products : [SubcategoryItem] { get set }

    var currentPage : Int { get }
    var isLastPage: Bool { get }
    var model : AllProductsModel { get set }
    var selectedCategory : DelegateCategory? { get set}
        
    func getDelegateProducts()
    func resetData()
}

final class AllProductsVM: BaseViewModel,AllProductsVMProtocol {
 
    @Published var delegateProducts: BaseResponse<DelegateProductsResponse>?
    
    var delegateProductsPublisher: Published<BaseResponse<DelegateProductsResponse>?>.Publisher { $delegateProducts }
    var searchTextSubject = PassthroughSubject<String, Never> .init()

    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var products : [SubcategoryItem] = []

    let delegateId : Int
    let delegateCategories : [DelegateCategory]

    var currentPage:Int = 1
    var isLastPage: Bool = false
    var model : AllProductsModel = AllProductsModel(delegateId: 0 , categorySlug: nil , search:  nil)
    var selectedCategory : DelegateCategory? = nil

    
    init(delegateId : Int , delegateCategories : [DelegateCategory]){
        self.delegateId = delegateId
        self.delegateCategories = delegateCategories
        model.delegateId = delegateId
    }

    func getDelegateProducts(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getDelegateProducts(model: model, page: currentPage))
                
                let products = result.data?.products ?? []
                
                if self.currentPage == 1 {
                    self.products.removeAll()
                    self.products = products
                } else {
                    self.products.append(contentsOf: products)
                }
                
                self.isLastPage = result.data?.pagination.isLastPage ?? false
                if !isLastPage {
                    self.currentPage += 1
                }
                
                delegateProducts = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func resetData(){
        currentPage = 1
        isLastPage = false
    }
}

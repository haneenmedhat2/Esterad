//
//  AllCategoriesVM.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import Foundation
import Combine

protocol AllCategoriesVMProtocol {
    var categoryPublisher: Published<BaseResponse<CategoryResponse>?>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var categoryList : [Category] { get }
    var pickerList : [PickerModel] { get }
    var isGuest : Bool { get }

    func categoryRequest()
    func convertToPickerList()
}

final class AllCategoriesVM: BaseViewModel,AllCategoriesVMProtocol {
 
    @Published var category: BaseResponse<CategoryResponse>?

    var categoryPublisher: Published<BaseResponse<CategoryResponse>?>.Publisher { $category}
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var categoryList : [Category] = []
    var pickerList : [PickerModel] = []
    var isGuest : Bool = UserDefaults.guest

    func categoryRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getCategories())
                categoryList = result.data?.categories ?? []
                convertToPickerList()
                category = result

                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func convertToPickerList(){
       pickerList = categoryList.map { category in
           PickerModel(id: category.id,
                       name: category.name,
                        mainSectionId: nil,
                        carTypeId: nil,
                        apiValue: nil,
                       image: category.image,
                       slug: category.slug)
        }
    }
}

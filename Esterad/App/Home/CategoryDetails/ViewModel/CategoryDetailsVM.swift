//
//  CategoryDetailsVM.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import Foundation
import Combine

protocol CategoryDetailsVMProtocol {
    var subcategoryPublisher: Published<BaseResponse<SubcategoriesResponse>?>.Publisher { get }
    var importingCountriesPublisher: Published<BaseResponse<ImportingCountriesResponse>?>.Publisher { get }
    var carCompaniesPublisher: Published<BaseResponse<CarCompaniesResponse>?>.Publisher { get }
    var carTypePublisher: Published<BaseResponse<CarTypeResponse>?>.Publisher { get }
    var carModelPublisher: Published<BaseResponse<CarModelResponse>?>.Publisher { get }
    var mainSectionPublisher: Published<BaseResponse<MainSectionResponse>?>.Publisher { get }
    var subSectionPublisher: Published<BaseResponse<SubSectionResponse>?>.Publisher { get }
    var searchTextSubject : PassthroughSubject<String, Never> { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    var subCategoryList : [SubcategoryItem] { get }
    var importingCountriesList : [PickerModel] { get }
    var carCompaniesList : [PickerModel] { get }
    var carTypeList : [PickerModel] { get }
    var carModelList : [PickerModel] { get }
    var mainSectionList : [PickerModel] { get }
    var subSectionList : [PickerModel] { get set }
    var stateList : [PickerModel] { get }
    var transmissionList : [PickerModel] { get }
    var fuelTypeList : [PickerModel] { get }
    
    var currentPage : Int { get }
    var isLastPage: Bool { get }
    
    var category:Category { get }
    var type : HomeModeTypes { get set }
    var model : SubcategoriesModel { get set }

    func getSubcategory()
    func getImportingCountries()
    func getCarCompanies()
    func getCarType()
    func getCarModel(carTypeId: Int)
    func getMainSections()
    func getSubSections(mainSectionId : Int)
    func resetData()
}

final class CategoryDetailsVM: BaseViewModel,CategoryDetailsVMProtocol {
    
    @Published var subcategory: BaseResponse<SubcategoriesResponse>?
    @Published var importingCountries: BaseResponse<ImportingCountriesResponse>?
    @Published var carCompanies: BaseResponse<CarCompaniesResponse>?
    @Published var carTypes: BaseResponse<CarTypeResponse>?
    @Published var carModels: BaseResponse<CarModelResponse>?
    @Published var mainSections: BaseResponse<MainSectionResponse>?
    @Published var subSections: BaseResponse<SubSectionResponse>?
    var searchTextSubject = PassthroughSubject<String, Never> .init()

    var subcategoryPublisher: Published<BaseResponse<SubcategoriesResponse>?>.Publisher { $subcategory }
    var importingCountriesPublisher: Published<BaseResponse<ImportingCountriesResponse>?>.Publisher { $importingCountries }
    var carCompaniesPublisher: Published<BaseResponse<CarCompaniesResponse>?>.Publisher { $carCompanies }
    var carTypePublisher: Published<BaseResponse<CarTypeResponse>?>.Publisher { $carTypes }
    var carModelPublisher: Published<BaseResponse<CarModelResponse>?>.Publisher { $carModels }
    var mainSectionPublisher: Published<BaseResponse<MainSectionResponse>?>.Publisher { $mainSections }
    var subSectionPublisher: Published<BaseResponse<SubSectionResponse>?>.Publisher { $subSections }
    
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    var subCategoryList : [SubcategoryItem] = []
    var importingCountriesList : [PickerModel] = []
    var carCompaniesList : [PickerModel] = []
    var carTypeList : [PickerModel] = []
    var carModelList : [PickerModel] = []
    var mainSectionList : [PickerModel] = []
    var subSectionList : [PickerModel] = []
    var stateList : [PickerModel]  = ProductState.pickerModels
    var transmissionList : [PickerModel] = CarGear.pickerModels
    var fuelTypeList : [PickerModel] = FuelType.pickerModels
    var currentPage:Int = 1
    var isLastPage: Bool = false

    var category:Category
    var type : HomeModeTypes = HomeModeTypes.products
    var model : SubcategoriesModel = SubcategoriesModel(type: "" , categorySlug: "")
    
    init(category:Category){
        self.category = category
        model.type = type.apiName
        model.categorySlug = category.slug
    }
    
    
    func getSubcategory(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getSubcategories(model: model, page: currentPage))
                
                let subCategoryList = result.data?.subcategories ?? []
                
                if self.currentPage == 1 {
                    self.subCategoryList.removeAll()
                    self.subCategoryList = subCategoryList
                } else {
                    self.subCategoryList.append(contentsOf: subCategoryList)
                }
                
                self.isLastPage = result.data?.pagination.isLastPage ?? false
                if !isLastPage {
                    self.currentPage += 1
                }
                
                subcategory = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getImportingCountries(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getImportingCountries())
                importingCountriesList = result.data?.countries ?? []
                importingCountries = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getCarCompanies(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getCarCompanies())
                carCompaniesList = result.data?.carCompanies ?? []
                carCompanies = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getCarType(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getCarType())
                carTypeList = result.data?.carTypes ?? []
                carTypes = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getCarModel(carTypeId: Int){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getCarModel(carTypeId: carTypeId))
                carModelList = result.data?.carModels ?? []
                carModels = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func getMainSections(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getMainSection())
                mainSectionList = result.data?.mainSections ?? []
                mainSections = result
                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    func getSubSections(mainSectionId : Int){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(HomeEndPoints.getSubSection(mainSectionId: mainSectionId))
                subSectionList = result.data?.subSections ?? []
                subSections = result
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

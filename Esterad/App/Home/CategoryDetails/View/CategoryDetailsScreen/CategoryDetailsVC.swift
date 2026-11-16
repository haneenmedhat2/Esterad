//
//  CategoryDetailsVC.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import UIKit

class CategoryDetailsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var homeModeView: HomeModeTypesView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties -
    
    var viewModel : CategoryDetailsVMProtocol
   
    //MARK: - Initializer -
    
    init(viewModel : CategoryDetailsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "CategoryDetailsVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initialConfiguration()
    }
    
    //MARK: - Initial Setup -
    
    func initialConfiguration(){
        self.title = viewModel.category.name
        bindViewModel()
        configureCollectionView()
        setupView()
        viewModel.getSubcategory()
    }
    
    func setupView(){
        homeModeView.delegate = self
        homeModeView.category = viewModel.category
        searchTextField.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.subcategoryPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)
        
        viewModel.searchTextSubject
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.viewModel.model.search = nil
                    self.viewModel.resetData()
                    self.viewModel.getSubcategory()
                    return
                }
                self.viewModel.model.search = text
                self.viewModel.resetData()
                self.viewModel.getSubcategory()
            }.store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapFilter(_ sender: UIButton) {
        let filterPopup = FilterPopup(viewModel: CategoryDetailsVM(category: viewModel.category),category: viewModel.category, isProduct: viewModel.type == .products , model : viewModel.model )
        filterPopup.delegate = self
        filterPopup.appear(sender: self)
    }
    
    @objc private func searchChanged(_ textField: UITextField) {
        viewModel.searchTextSubject.send(textField.text ?? "")
    }
}

//MARK: - HomeModeView Delegation -

extension CategoryDetailsVC : HomeModeTypesDelegate {
    func didSelectItem(at type: HomeModeTypes) {
        switch type {
        case .products:
            searchTextField.placeholder = "search_by_product_name".localized
            viewModel.type = type
            viewModel.model.type = type.apiName
            viewModel.resetData()
            viewModel.getSubcategory()
            
        case .companies:
            searchTextField.placeholder = "search_by_company_name".localized
            viewModel.type = type
            viewModel.model.type = type.apiName
            viewModel.resetData()
            viewModel.getSubcategory()
        }
    }
}

//MARK: - Collection View Configuration -

extension CategoryDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: ProductCell.self)
        collectionView.register(cellType: CompanyCell.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.subCategoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.type {
            
        case .products:
            let cell = collectionView.dequeueReusableCell(with: ProductCell.self, for: indexPath)
            let item = viewModel.subCategoryList[indexPath.row]
            cell.setupCell(model: item)
            return cell
            
        case .companies:
            let cell = collectionView.dequeueReusableCell(with: CompanyCell.self, for: indexPath)
            let item = viewModel.subCategoryList[indexPath.row]
            cell.setupCell(model: item, category: viewModel.category)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.type {
        case .products:
            let item =  viewModel.subCategoryList[indexPath.row]
            let vc = ProductDetailsVC(viewModel: ProductDetailsVM(productId: item.id ?? 0))
            push(vc)
        case .companies:
            let item =  viewModel.subCategoryList[indexPath.row]
            let vc = CompanyDetailsVC(viewModel: CompanyDetailsVM(delegateId: item.id ?? 0, categoryId: viewModel.category.id ?? 0))
            push(vc)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.subCategoryList.count - 1,
           !viewModel.isLastPage {
            viewModel.getSubcategory()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = layout.minimumInteritemSpacing
        let insets = layout.sectionInset.left + layout.sectionInset.right
        
        let availableWidth = collectionView.frame.width - spacing - insets
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: 182)
    }
}

//MARK: - FilterPopup Delegation -

extension CategoryDetailsVC : FilterPopupDelegate {
    func didSelectFilter(model: SubcategoriesModel) {
        viewModel.model = model
        viewModel.resetData()
        viewModel.getSubcategory()
    }
}

//MARK: - EmptyState  -

extension CategoryDetailsVC {
    func updateEmptyState() {
        if viewModel.subCategoryList.isEmpty {
            collectionView.setEmptyState(
                image: UIImage(resource: .searchPlaceholder),
                message: "No search results found".localized
            )
        } else {
            collectionView.removeEmptyState()
        }
    }
}

//
//  AllProductsVC.swift
//  Esterad
//
//  Created by Haneen on 24/11/2025.
//

import UIKit

class AllProductsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    
    //MARK: - Properties -
    
    var viewModel : AllProductsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : AllProductsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "AllProductsVC", bundle: nil)
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
        self.title = "products".localized
        view.isHidden = true
        configureCollectionView()
        viewSetup()
        bindViewModel()
        viewModel.getDelegateProducts()
    }
    
    func viewSetup(){
        searchTextField.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        viewModel.delegateProductsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                view.isHidden = false
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)
        
        viewModel.searchTextSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    viewModel.model.search = nil
                } else {
                    viewModel.model.search = text
                }
                viewModel.resetData()
                viewModel.getDelegateProducts()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapFilter(_ sender: UIButton) {
        let popup = CategoryFilterPopup(delegateCategories: viewModel.delegateCategories)
           popup.selectedItem = viewModel.selectedCategory
           popup.delegate = self
           popup.appear(sender: self)
    }
    
    @objc private func searchChanged(_ textField: UITextField) {
        viewModel.searchTextSubject.send(textField.text ?? "")
    }
}

//MARK: - Collection View Configuration -

extension AllProductsVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: ProductCell.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ProductCell.self, for: indexPath)
        let item = viewModel.products[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item =  viewModel.products[indexPath.row]
        let vc = ProductDetailsVC(viewModel: ProductDetailsVM(productId: item.id ?? 0))
        push(vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.products.count - 1,
           !viewModel.isLastPage {
            self.viewModel.getDelegateProducts()
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
        
        return CGSize(width: cellWidth, height: 185)
    }
}

//MARK: - EmptyState  -

extension AllProductsVC {
    func updateEmptyState() {
        if viewModel.products.isEmpty {
            collectionView.setEmptyState(
                image: UIImage(resource: .emptyProducts),
                message: "no_products".localized
            )
        } else {
            collectionView.removeEmptyState()
        }
    }
}

//MARK: - Delegation -
extension AllProductsVC : CategoryFilterDelegate{
    func didDismissPopup(model: DelegateCategory?) {
        viewModel.selectedCategory = model
        viewModel.model.categorySlug = model?.pickerSlug
        viewModel.resetData()
        viewModel.getDelegateProducts()
    }
}

//
//  AllCategoriesVC.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import UIKit

class AllCategoriesVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties -
    
    let viewModel : AllCategoriesVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : AllCategoriesVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "AllCategoriesVC", bundle: nil)
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
        self.title = "all_categories".localized
        bindViewModel()
        viewModel.categoryRequest()
        configureCollectionView()
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.categoryPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}

//MARK: - Collection View Setup -

extension AllCategoriesVC : UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    func categorySection()->NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1)
                                              , heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1)
                                               , heightDimension: .absolute(140))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize
                                                     , subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0
                                                      , bottom: 8, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10
                                                        , bottom: 8, trailing: 10)
        
        return section
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: CategoryCell.self)
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            default:
                return self.categorySection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: CategoryCell.self, for: indexPath)
        let item = viewModel.categoryList[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.categoryList[indexPath.row]
        goToCategoryDetails(category : item)
    }
}

//MARK: - Routes -

extension AllCategoriesVC {
    
    func goToCategoryDetails(category : Category){
        let vc = CategoryDetailsVC(viewModel: CategoryDetailsVM(category: category))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
}

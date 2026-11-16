//
//  ReviewsVC.swift
//  Esterad
//
//  Created by Haneen on 25/11/2025.
//

import UIKit
import Combine

class ReviewsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: CollectionViewContentSized!
    
    //MARK: - Properties -
    
    var viewModel : ReviewsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ReviewsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ReviewsVC", bundle: nil)
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
        self.title = "reviews".localized
        configureCollectionView()
        bindViewModel()
        viewModel.getDelegateReviews()
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.delegateReviewsPublisher
            .sinkOnMain { [weak self] _ in
                guard let self = self else { return }
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}

//MARK: - CollectionView Configuration -

extension ReviewsVC : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: ClientRatingCell.self, bundle: nil)
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return self.reviewsSection()
            default:
                return self.reviewsSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func reviewsSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)


        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        section.interGroupSpacing = 12
        return section
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reviewsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ClientRatingCell.self, for: indexPath)
        let item = viewModel.reviewsList[indexPath.row]
        cell.setupCell(with: item)
        return cell
    }
}

//MARK: - Empty state -

extension ReviewsVC {
    func updateEmptyState() {
        if viewModel.reviewsList.isEmpty {
            collectionView.setEmptyState(
                image: UIImage(resource: .emptyReviews),
                message: "no_reviews".localized
            )
        } else {
            collectionView.removeEmptyState()
        }
    }
}

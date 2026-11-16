//
//  CompanyDetailsVC.swift
//  Esterad
//
//  Created by Haneen on 20/11/2025.
//

import UIKit

class CompanyDetailsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createCustomRequestBtn: IconTextGeneralButton!
    
    //MARK: - Properties -
    
    var viewModel : CompanyDetailsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : CompanyDetailsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "CompanyDetailsVC", bundle: nil)
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
        self.title = "company_details".localized
        view.isHidden = true
        if UserMode.current == .authenticated {
            setupChatButton()
        }
        configureCollectionView()
        bindViewModel()
        viewModel.getCompanyDetails()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCreateCustomRequest))
        createCustomRequestBtn.addGestureRecognizer(tap)
    }
    
    private func setupChatButton() {
        let chatButton = UIButton(type: .system)
        chatButton.setImage(
            UIImage(resource: .chatEnabled),
            for: .normal
        )
        chatButton.tintColor = .main
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatButton.widthAnchor.constraint(equalToConstant: 45),
            chatButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        chatButton.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatButton)
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        viewModel.companyDetailsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                view.isHidden = false
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.privateRoomPublisher
            .compactMap { $0 }
            .sinkOnMain { [weak self] response in
                self?.openChat(response: response)
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @objc func didTapCreateCustomRequest() {
        switch UserMode.current {
        case .authenticated:
            goToSpecialRequestForm()
        case .guest:
            showGuestPopup()
        }
    }
    
    @objc private func didTapChat() {
        viewModel.createPrivateRoom()
    }

    private func openChat(response: BaseResponse<SingleRoomResponse>) {
        guard let roomId = response.data?.room.id else { return }
        let senderName = viewModel.delegateModel?.name ?? ""
        
        if UserDefaults.isChatTermsAccepted(roomId: roomId) {
            goToChat(response: response, senderName: senderName)
        } else {
            goToChatTerms(response: response, senderName: senderName)
        }
    }
    
    private func goToChat(response: BaseResponse<SingleRoomResponse>, senderName: String) {
        let chatVC = ChatVC(
            viewModel: ChatVM(
                providerId: viewModel.delegateId,
                senderName: senderName,
                initialResponse: response
            )
        )
        chatVC.hidesBottomBarWhenPushed = true
        push(chatVC)
    }
    
    private func goToChatTerms(response: BaseResponse<SingleRoomResponse>, senderName: String) {
        let termsVC = TermsAndConditionsVC(
            viewModel: TermsAndConditionsVM(
                model: .companyChat(
                    providerId: viewModel.delegateId,
                    senderName: senderName,
                    response: response
                )
            )
        )
        termsVC.hidesBottomBarWhenPushed = true
        push(termsVC)
    }
}

//MARK: - CollectionView Configuration -
extension CompanyDetailsVC : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func detailsSection()->NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(400)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func productsSection(isEmpty: Bool) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupHeight: CGFloat = isEmpty ? 160 : 182
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(groupHeight)
        )
        
        let group: NSCollectionLayoutGroup
        
        if isEmpty {
            group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
        } else {
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 2
            )
            group.interItemSpacing = .fixed(12)
        }
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        
        section.boundarySupplementaryItems = [
            .init(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(40)
                ),
                elementKind: CategoryHeaderView.elementKind,
                alignment: .top
            )
        ]
        
        return section
    }
    
    func reviewsSection(isEmpty: Bool) -> NSCollectionLayoutSection {
        let groupHeight: CGFloat = isEmpty ? 160 : 100
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(groupHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(groupHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        section.interGroupSpacing = 12
        
        section.boundarySupplementaryItems = [
            .init(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(40)
                ),
                elementKind: CategoryHeaderView.elementKind,
                alignment: .top
            )
        ]
        
        return section
    }
    
    
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: CompanyDetailsCollectionCell.self)
        collectionView.register(cellType: ProductCell.self)
        collectionView.register(cellType: ClientRatingCell.self)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: "EmptyStateCell")
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: CategoryHeaderView.elementKind,
                                withReuseIdentifier: CategoryHeaderView.headerIdentifier)
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return self.detailsSection()
            case 1:
                return self.productsSection(isEmpty: self.viewModel.products.isEmpty)
            case 2:
                return self.reviewsSection(isEmpty: self.viewModel.reviewsList.isEmpty)
            default:
                return nil
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel.products.isEmpty ? 1 : min(viewModel.products.count, 2)
        case 2:
            return viewModel.reviewsList.isEmpty ? 1 : min(viewModel.reviewsList.count, 2)
        default:
            return 0
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(with: CompanyDetailsCollectionCell.self, for: indexPath)
            guard let model = viewModel.delegateModel else { return cell }
            cell.configure(with: model)
            cell.delegate = self
            return cell
            
        case 1:
            if viewModel.products.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                cell.configure(image: .emptyProducts, message: "no_products".localized)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(with: ProductCell.self, for: indexPath)
                cell.setupCell(model: viewModel.products[indexPath.row])
                return cell
            }
            
        case 2:
            if viewModel.reviewsList.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                cell.configure(image: .emptyReviews, message: "no_reviews".localized)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(with: ClientRatingCell.self, for: indexPath)
                cell.setupCell(with: viewModel.reviewsList[indexPath.row])
                return cell
            }
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1,
              viewModel.products.indices.contains(indexPath.item) else {
            return
        }
        
        let item = viewModel.products[indexPath.item]
        goToProductDetails(productId: item.id ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard !(collectionView.cellForItem(at: indexPath) is EmptyStateCell) else {
            return false
        }
        
        return indexPath.section == 1 &&
        viewModel.products.indices.contains(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        var title = ""
        var headerType : HeaderTypes = .product
        switch indexPath.section {
        case 1:
            title = "products".localized
            headerType = .product
        case 2:
            title = "customer_reviews".localized
            headerType = .rate
        default:
            break
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: CategoryHeaderView.elementKind,
            withReuseIdentifier: CategoryHeaderView.headerIdentifier,
            for: indexPath
        ) as! CategoryHeaderView
        
        header.configure(title: title, isIconHidden: true, showAllButtonHidden: false, headerType: headerType)
        header.delegate = self
        return header
    }
}


//MARK: - HeaderView Delegation  -

extension CompanyDetailsVC : CategoryHeaderViewDelegate {
    func didTapShowAll(headerType: HeaderTypes?) {
        switch headerType {
        case .product:
            goToAllProducts()
        case .rate:
            goToReviews()
        default:
            break
        }
    }
}

//MARK: - Delegation -
extension CompanyDetailsVC : CompanyDetailsProtocol {
    func didSelectFilter() {
        goToAllProducts()
    }
}

//MARK: - Routes -

extension CompanyDetailsVC {
    
    func goToProductDetails(productId : Int){
        let vc = ProductDetailsVC(viewModel: ProductDetailsVM(productId: productId))
        push(vc)
    }
    
    func goToAllProducts(){
        let vc = AllProductsVC(viewModel: AllProductsVM(delegateId: viewModel.delegateId, delegateCategories: viewModel.categories))
        push(vc)
    }
    
    func goToReviews(){
        let vc = ReviewsVC(viewModel: ReviewsVM(delegateId: viewModel.delegateId))
        push(vc)
    }
    
    func goToSpecialRequestForm(){
        let vc = SpecialRequestVC(viewModel: SpecialRequestVM(delegateId: viewModel.delegateId, categoryId: viewModel.categoryId))
        push(vc)
    }
    
    func showGuestPopup(){
        let vc = GuestLoginPopup()
        vc.appear(sender: self)
    }
}

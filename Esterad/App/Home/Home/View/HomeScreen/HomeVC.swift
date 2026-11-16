//
//  HomeVC.swift
//  Esterad
//
//  Created by Haneen on 15/10/2025.
//

import UIKit

class HomeVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var adsView: BannerSliderView!
    
    //MARK: - Properties -
    
    let viewModel : HomeVMProtocol
    let refreshController = UIRefreshControl()

    private lazy var noAdsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "no_ads".localized
        label.textColor = .lightGray
        label.font = UIFont.myBookFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 145).isActive = true
        return label
    }()
    
    //MARK: - Initializer -
    
    init(viewModel : HomeVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "HomeVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initialConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserMode.current == .authenticated {
            setupAddressLabel()
        }
    }
    
    //MARK: - Initial Setup -
    
    func initialConfiguration(){
        bindViewModel()
        viewModel.gethomeData()
        setupNotificationButton()
        configureCollectionView()
        setupNoAdsPlaceholder()
        if  UserMode.current == .guest {
            navigationItem.leftBarButtonItem?.isHidden = true
        }
        setupRefreshControl()
        
        adsView.didSelectAddress = { [weak self] item in
            guard let self = self else { return }
            switch item.linkType {
            case .product:
                self.goToProductDetails(productId : item.productId ?? 0)
            case .delegate:
                self.goToCompanyDetails(delegateId: item.delegateId ?? 0, categoryId: item.categoryId ?? 0 )
            default :
                return
            }
        }
    }
    
    private func setupAddressLabel() {
        let iconImageView = UIImageView(image: UIImage(resource: .location10))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .black
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let label = UILabel()
        label.font = UIFont.myBookFont(ofSize: 14)
        label.textColor = .black
        label.text = UserDefaults.user?.address ?? "No address was found."
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(
            lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.6
        ).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAddressLabel))
        stackView.addGestureRecognizer(tap)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    private func setupNoAdsPlaceholder() {
        guard let adsIndex = containerStackView.arrangedSubviews.firstIndex(of: adsView) else { return }
        containerStackView.insertArrangedSubview(noAdsPlaceholderLabel, at: adsIndex + 1)
    }

    func setupRefreshControl(){
        if let scrollView = containerStackView.superview as? UIScrollView {
            scrollView.alwaysBounceVertical = true
            refreshController.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            scrollView.refreshControl = refreshController
        }
   
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.homePublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.refreshController.endRefreshing()
                self.collectionView.reloadData()
                let ads = result?.data?.ads ?? []
                self.adsView.setSliderList(list: ads)
                self.adsView.isHidden = ads.isEmpty
                self.noAdsPlaceholderLabel.isHidden = !ads.isEmpty
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    
    //MARK: - Action -
    
    @objc func didTapOnAddressLabel(){
        goToChooseLocation()
    }
    
    @objc func refreshData(){
        viewModel.gethomeData()
    }
}

//MARK: - Routes -

extension HomeVC {
    func goToChooseLocation(){
        let vc = ChooseLocationVC(viewModel: ChooseLocationVM())
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func goToNotification(){
        let vc = NotificationVC(viewModel: NotificationVM())
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func goToAllCategories(){
        let vc = AllCategoriesVC(viewModel: AllCategoriesVM())
        vc.hidesBottomBarWhenPushed = true 
        push(vc)
    }
    
    func goToCategoryDetails(category : Category){
        let vc = CategoryDetailsVC(viewModel: CategoryDetailsVM(category: category))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func goToProductDetails(productId : Int){
        let vc = ProductDetailsVC(viewModel: ProductDetailsVM(productId: productId))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func goToCompanyDetails(delegateId : Int ,categoryId : Int){
        let vc = CompanyDetailsVC(viewModel: CompanyDetailsVM(delegateId: delegateId , categoryId: categoryId))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
}

//MARK: - Collection View Setup -

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    
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
        
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45)), elementKind:  CategoryHeaderView.elementKind, alignment: .top),
        ]
        
        return section
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: CategoryCell.self)
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: CategoryHeaderView.elementKind,
                                withReuseIdentifier: CategoryHeaderView.headerIdentifier)
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0:
                return self.categorySection()
            default:
                return self.categorySection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.categoryList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(with: CategoryCell.self, for: indexPath)
            let item = viewModel.categoryList[indexPath.row]
            cell.setupCell(model: item)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let item = viewModel.categoryList[indexPath.row]
                goToCategoryDetails(category : item)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.headerIdentifier,
            for: indexPath
        ) as! CategoryHeaderView
        header.delegate = self
        return header
    }
}

extension HomeVC : CategoryHeaderViewDelegate {
    func didTapShowAll(headerType: HeaderTypes?) {
        goToAllCategories()
    }
}

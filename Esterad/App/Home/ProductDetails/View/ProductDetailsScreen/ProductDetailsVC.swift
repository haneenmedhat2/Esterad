//
//  ProductDetailsVC.swift
//  Esterad
//
//  Created by Haneen on 19/11/2025.
//

import UIKit
import Kingfisher

class ProductDetailsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productPriceBefore: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mainCategoryLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var carCompanyLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var transmissionTypeLabel: UILabel!
    @IBOutlet weak var fuelTypeLabel: UILabel!
    @IBOutlet weak var engineCapacityLabel: UILabel!
    @IBOutlet weak var carSectionLabel: UILabel!
    @IBOutlet weak var carDetailsView: UIView!
    @IBOutlet weak var furnitureDetailsView: UIView!
    @IBOutlet weak var importCountryLabel: UILabel!
    @IBOutlet weak var customFeesLabel: UILabel!
    @IBOutlet weak var initialDeliveryPriceLabel: UILabel!
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    @IBOutlet weak var mainCategoryStackView: UIStackView!
    @IBOutlet weak var subCategoryStackView: UIStackView!
    @IBOutlet weak var fuelTypeStackView: UIStackView!
    @IBOutlet weak var orderNowButton: MainButton!
    @IBOutlet weak var purshasedView: UIView!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var taxValueLabel: UILabel!
    
    //MARK: - Properties -
    
    var viewModel : ProductDetailsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ProductDetailsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ProductDetailsVC", bundle: nil)
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
        self.title = "product_details".localized
        view.isHidden = true
        bindViewModel()
        configureCollectionView()
        viewModel.getProductDetails()
        setupShareButton()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProductImg))
        productImage.addGestureRecognizer(tap)
    }
    
    private func setupShareButton(){
        let shareBtn = UIButton(type: .system)
        shareBtn.layer.masksToBounds = false
        shareBtn.layer.shadowColor = UIColor.black.cgColor
        shareBtn.layer.shadowOpacity = 0.1
        shareBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        shareBtn.layer.shadowRadius = 4
        shareBtn.setImage(UIImage(resource: .share).withRenderingMode(.alwaysOriginal), for: .normal)
        
        NSLayoutConstraint.activate([
            shareBtn.widthAnchor.constraint(equalToConstant: 25),
            shareBtn.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        shareBtn.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: shareBtn)
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.productDetailsPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                view.isHidden = false
                self.collectionView.reloadData()
                guard let product = result?.data?.product else { return }
                self.setupData(product : product)
            }
            .store(in: &cancellables)
        
        viewModel.productAvailabilityPublisher
            .compactMap { $0 }
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.showPopup()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    func setupData(product : Product){
        
        if viewModel.showCarDetailsView {
            carDetailsView.isHidden = false
            furnitureDetailsView.isHidden = true
        } else {
            carDetailsView.isHidden = true
            furnitureDetailsView.isHidden = false
        }
        
        if let mainSectionName = product.mainSectionName, !mainSectionName.trimWhiteSpace().isEmpty {
            mainCategoryLabel.text = mainSectionName
        } else {
            mainCategoryStackView.isHidden = true
        }
        
        if let subSectionName = product.subsectionName, !subSectionName.trimWhiteSpace().isEmpty{
            subCategoryLabel.text = subSectionName
        } else {
            subCategoryStackView.isHidden = true
        }
        
        if let fuelType = product.fuelType, !fuelType.trimWhiteSpace().isEmpty {
            fuelTypeLabel.text = product.fuelTypeText
        } else {
            fuelTypeStackView.isHidden = true
        }
        
        if let discountPrice = product.discountPrice, !discountPrice.trimWhiteSpace().isEmpty {
            
            productPrice.text = (product.discountPrice ?? "") +  "SAR".localized
            productPriceBefore.text = (product.price ?? "") + "SAR".localized
            productPriceBefore.addLineThrough()
            
        } else {
            productPriceBefore.isHidden = true
            productPrice.text = (product.price ?? "") +  "SAR".localized
        }
     
        purshasedView.isHidden = !(product.isPurchased ?? false )
        productTitle.text = product.name
        descriptionTextView.text = product.desc
        sectionLabel.text = product.categoryName
        carCompanyLabel.text = product.carCompanyName
        brandLabel.text = product.carTypeName
        carModelLabel.text = product.carModelName
        conditionLabel.text = product.status
        transmissionTypeLabel.text = product.transmissionText
        engineCapacityLabel.text = product.engineCapacity
        carSectionLabel.text = product.categoryName
        importCountryLabel.text = product.importingCountryName
        customFeesLabel.text = product.customsFees?.toPrice
        initialDeliveryPriceLabel.text = product.initialDeliveryPrice?.toPrice
        deliveryTimeLabel.text = (product.minEstimatedDeliveryDuration ?? "0") + ":" + (product.maxEstimatedDeliveryDuration ?? "0")
        productImage.kf.setImage(with: URL(string: viewModel.productImageList.first?.image ?? ""),placeholder: UIImage(resource:.furniturePlaceholder), options: [.onFailureImage(UIImage(resource: .furniturePlaceholder))])
        
        
        let title = String(format: "purchase_commitment".localized,product.downPaymentPrice ?? "0.0")
        orderNowButton.setTitle(title, for: .normal)
        orderNowButton.isEnabled = !(product.isPurchased ?? false )
        orderNowButton.alpha = orderNowButton.isEnabled ? 1 : 0.4
        
        totalValueLabel.text = "app_name".localized + " " + (product.totalPrice?.toPrice ?? "")
        
        taxValueLabel.text = product.addedValue?.toPrice ?? ""
        
    }
    
    //MARK: - Action -
    
    @objc func didTapShare() {
        openShareSheet()
    }
    
    @objc func didTapProductImg(){
        if viewModel.productImageList.isEmpty { return }
        let image = viewModel.productImageList[viewModel.selectedIndex.row].image ?? ""
        goToImageViewer(url : image)
    }
    
    @IBAction func didTapOrderNow(_ sender: UIButton) {
        switch UserMode.current {
        case .authenticated:
           // goToTerms()
            viewModel.askProductAvailability()
        case .guest:
            showGuestPopup()
        }
    }
}

//MARK: - CollectionView Configuration -
extension ProductDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
 
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = .zero
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ProductImageCell.self, forCellWithReuseIdentifier: "ProductImageCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ProductImageCell.self, for: indexPath)
        var item = viewModel.productImageList[indexPath.row]
        item.isSelected = indexPath == viewModel.selectedIndex
        cell.setupCell(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.productImageList[indexPath.row]
        productImage.kf.setImage(with: URL(string: item.image ?? ""),placeholder: UIImage(resource:.furniturePlaceholder),
                                 options: [.onFailureImage(UIImage(resource: .furniturePlaceholder))])
        viewModel.selectedIndex = indexPath
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: 60)
    }
}

//MARK: - Routes -

extension ProductDetailsVC {
    func goToImageViewer(url : String){
        let vc = ImageViewerVC(viewModel: ImageViewerVM(imgURL: url))
        vc.appear(sender: self)
    }
    
    private func openShareSheet() {
        let id = viewModel.productId
        let urlString = NetworkConstants.domain + "/product/\(id)"
        guard let link = URL(string: urlString) else { return }
        let activityController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func showGuestPopup(){
        let vc = GuestLoginPopup()
        vc.appear(sender: self)
    }
    
    func goToTerms(){
        let vc = TermsAndConditionsVC(viewModel: TermsAndConditionsVM(model: .order(productId: viewModel.productId, price: viewModel.downPaymentPrice)))
        push(vc)
    }
    
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .checkAvailability)
        vc.onPopupHidden = { [weak self ] in
            guard let self = self else { return }
            popToRoot()
        }
    }
}

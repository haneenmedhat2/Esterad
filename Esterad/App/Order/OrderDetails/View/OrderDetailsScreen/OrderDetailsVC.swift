//
//  OrderDetailsVC.swift
//  Esterad
//
//  Created by Haneen on 01/12/2025.
//

import UIKit
import Kingfisher

class OrderDetailsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var purchaseAmountLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var productIcon: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var companyIcon: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var cancellationReasonTextView: UITextView!
    @IBOutlet weak var confirmOrderButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var cancelOrderView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var productTypeStackView: UIStackView!
    @IBOutlet weak var quantityStackView: UIStackView!
    @IBOutlet weak var budgetStackView: UIStackView!
    @IBOutlet weak var purchaseAmountStackView: UIStackView!
    @IBOutlet weak var paymentMethodStackView: UIStackView!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var productSpecificationsView: UIView!
    @IBOutlet weak var productSpecificationsTextView: UITextView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var ProductDetailsView: UIView!
    @IBOutlet weak var acceptRejectStackView: UIStackView!
    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var acceptedOrderView: UIView!
    @IBOutlet weak var financialDetailsView: UIView!
    @IBOutlet weak var serviceCostLabel: UILabel!
    @IBOutlet weak var purchaseAmount: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var rejectionOrderView: UIView!
    @IBOutlet weak var rejectionTextView: UITextView!
    @IBOutlet weak var acceptOrderStatusLabel: UILabel!
    @IBOutlet weak var specialOderPaymentStack: UIStackView!
    @IBOutlet weak var providerResponseView: UIView!
    @IBOutlet weak var providerResponseLabel: UILabel!
    
    //MARK: - Properties -
    
    var viewModel : OrderDetailsVMProtocol
    private let refreshControl = UIRefreshControl()
    
    //MARK: - Initializer -
    
    init(viewModel :OrderDetailsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "OrderDetailsVC", bundle: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(isOrderChanged), name: .isOrderChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .isOrderChanged, object: nil)
    }
    
    //MARK: - Initial Setup -
    
    func initialConfiguration(){
        bindViewModel()
        self.title = "order_details:".localized
        view.isHidden = true
        viewModel.getOrderDetails()
        setupRefreshControl()
    }
    
    private func setupReportButton(){
        let reportBtn = UIButton(type: .system)
        reportBtn.layer.masksToBounds = false
        reportBtn.layer.shadowColor = UIColor.black.cgColor
        reportBtn.layer.shadowOpacity = 0.1
        reportBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        reportBtn.layer.shadowRadius = 4
        reportBtn.setImage(UIImage(resource: .reportOrder).withRenderingMode(.alwaysOriginal), for: .normal)
        
        NSLayoutConstraint.activate([
            reportBtn.widthAnchor.constraint(equalToConstant: 25),
            reportBtn.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        reportBtn.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: reportBtn)
    }
    
    private func setupRefreshControl() {
        if let scrollView = containerStackView.superview as? UIScrollView {
            scrollView.alwaysBounceVertical = true
            refreshControl.addTarget(self, action: #selector(isOrderChanged), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
    }
    
    //MARK: - ViewModel binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.orderDetailsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                guard let result = result?.data?.order else { return }
                view.isHidden = false
                self.refreshControl.endRefreshing()
                self.setupData(model: result)
            }
            .store(in: &cancellables)
        
        viewModel.hideCancelButton
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                cancelOrderButton.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.hideOrderConfirmationButton
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                confirmOrderButton.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.hideRateButton
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                rateButton.isHidden = isHidden
                
            }
            .store(in: &cancellables)
        
        viewModel.hideReportButton
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                navigationItem.rightBarButtonItem?.isHidden = isHidden
                if !isHidden {
                    setupReportButton()
                }
            }
            .store(in: &cancellables)
        
        viewModel.isChatActive
            .sinkOnMain { [weak self] isActive in
                guard let self = self else { return }
//                if isActive {
//                    chatButton.setImage(UIImage(resource: .chatEnabled), for: .normal)
//                } else {
//                    chatButton.setImage(UIImage(resource: .chatDisapled), for: .normal)
//                }
                chatButton.setImage(UIImage(resource: .chatEnabled), for: .normal)

            }
            .store(in: &cancellables)
        
        viewModel.hideCancellationView
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                cancelOrderView.isHidden = isHidden
                if isHidden {
                    buttonsView.backgroundColor = .white
                } else {
                    buttonsView.backgroundColor = .clear
                    buttonsView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.hideRejectionView
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                rejectionOrderView.isHidden = isHidden
                if isHidden {
                    buttonsView.backgroundColor = .white
                } else {
                    buttonsView.backgroundColor = .clear
                    buttonsView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.hideAcceptRejectButtons
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                acceptRejectStackView.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.hideChatButtons
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                chatStackView.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.hideAcceptanceView
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                acceptedOrderView.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.hideFinancialDetails
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                switch viewModel.orderType {
                case .normal:
                    financialDetailsView.isHidden = true
                case .special:
                    financialDetailsView.isHidden = isHidden
                }
            }
            .store(in: &cancellables)
        
        viewModel.hideSpecialOrderPaymentMethod
            .sinkOnMain { [weak self] isHidden in
                guard let self = self else { return }
                specialOderPaymentStack.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.addNewComplaintPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.showPopup()
            }
            .store(in: &cancellables)
        
        viewModel.cancelOrderPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "Message")
            }
            .store(in: &cancellables)
        
        viewModel.cancelOrderPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "Message")
            }
            .store(in: &cancellables)
        
        viewModel.confirmOrderPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "Message")
            }
            .store(in: &cancellables)
        
        viewModel.rateOrderPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "Message")
                pop()
            }
            .store(in: &cancellables)
                
        error(viewModel.errorPublisher)
    }
    
    private func setupData(model: OrderDetailsModel) {
        
        switch viewModel.orderType {
        case .normal:
            productTypeStackView.isHidden = true
            quantityStackView.isHidden = true
            budgetStackView.isHidden = true
            productSpecificationsView.isHidden = true
            notesView.isHidden = true
        case .special:
            purchaseAmountStackView.isHidden = true
            paymentMethodStackView.isHidden = true
            ProductDetailsView.isHidden = true
        }
        
        if model.isRated ?? true {
            buttonsView.isHidden = true
        }
        
        orderNumLabel.text = "#" + "\(model.id ?? 0)"
        orderStatusLabel.text = model.statusText
        sectionLabel.text = model.categoryName
        purchaseAmountLabel.text = model.downPaymentPrice?.toPrice
        paymentMethodLabel.text = model.paymentMethod?.name
        productIcon.kf.setImage(with: URL(string: model.productImage ?? ""))
        productTitle.text = model.productName
        productPrice.text = model.price?.toPrice
        companyIcon.kf.setImage(with: URL(string: model.delegateLogo ?? ""))
        companyNameLabel.text = model.delegateName
        cancellationReasonTextView.text = model.closeReason
        productTypeLabel.text = model.productType
        quantityLabel.text = "\(model.productQty ?? 0)"
        serviceCostLabel.text = model.price?.toPrice
        purchaseAmount.text = model.downPaymentPrice?.toPrice
        paymentMethod.text = model.paymentMethod?.name
        rejectionTextView.text = model.closeReason
        acceptOrderStatusLabel.text = model.offerStatus.note

        if let budget = model.expectedBudget , !budget.trimWhiteSpace().isEmpty , budget != "0.00"  {
            budgetLabel.text = budget.toPrice
        } else {
            budgetStackView.isHidden = true
        }
        productSpecificationsTextView.text = model.productDesc
        if let notes = model.notes , !notes.trimWhiteSpace().isEmpty {
            notesTextView.text = notes
        } else {
            notesTextView.text = "order_notes_placeholder".localized
        }

        let delegateNotes = model.delegateNotes?.trimWhiteSpace() ?? ""
        let shouldShowProviderResponse = model.orderType == .special && !delegateNotes.isEmpty
        providerResponseView.isHidden = !shouldShowProviderResponse
        providerResponseLabel.isHidden = !shouldShowProviderResponse
        providerResponseLabel.text = shouldShowProviderResponse ? delegateNotes : nil
    }
    
    //MARK: - Action -
 
    @objc func didTapReport() {
        showCreateComplaint()
    }
    
    @IBAction func didTapChat(_ sender: UIButton) {
        guard let roomId = viewModel.orderDetailsModel?.roomId else { return }

          if UserDefaults.isChatTermsAccepted(roomId: roomId) {
              goToChat()
          } else {
              goToTermsAndConditions()
          }
    }
    
    @IBAction func didTapConfirmOrder(_ sender: UIButton) {
        viewModel.confirmOrderRequest()
    }
    
    @IBAction func didTapCancelOrder(_ sender: UIButton) {
        showCancellationPopup()
    }
    
    @IBAction func didTapRate(_ sender: UIButton) {
        showRatePopup()
    }
    
    @IBAction func didTapAcceptOrder(_ sender: UIButton) {
        goToPayment()
    }
    
    @IBAction func didTapRejectOrder(_ sender: UIButton) {
        showRejectionPopup()
    }
    
    @objc private func isOrderChanged() {
        viewModel.getOrderDetails()
    }
}

//MARK: - Routes -

extension OrderDetailsVC {
    func showCreateComplaint(){
        let vc = CreateComplaintPopup()
        vc.delegate = self
        vc.appear(sender: self)
    }
    
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .createComplaint)
        vc.onPopupHidden = { [weak self ] in
            guard let self = self else { return }
            self.goToComplaints()
        }
    }
    
    func showCancellationPopup(){
        let vc = CancelOrderPopup(orderType : viewModel.orderType)
        vc.delegate = self
        vc.appear(sender: self)
    }
    
    func showRejectionPopup(){
        let vc = RejectOrderPopup()
        vc.delegate = self
        vc.appear(sender: self)
    }

    func showRatePopup(){
        let vc = RateOrderPopup()
        vc.delegate = self
        vc.appear(sender: self)
    }
    
    func goToPayment(){
        let vc = PaymentVC(viewModel: PaymentVM(productId: nil, productPrice : viewModel.orderDetailsModel?.downPaymentPrice ?? "", offerId: viewModel.orderDetailsModel?.deliveryOffer?.id, orderType: .special))
        vc.delegate = self
        push(vc)
    }
    
    func goToChat(){
        let vc = ChatVC(viewModel: ChatVM(roomId: viewModel.orderDetailsModel?.roomId ?? 0, senderName: viewModel.orderDetailsModel?.delegateName ?? ""))
        vc.delegate = self
        push(vc)
    }
    
    func goToTermsAndConditions(){
        let vc = TermsAndConditionsVC(viewModel: TermsAndConditionsVM(model: .chat(roomId: viewModel.orderDetailsModel?.roomId ?? 0, senderName: viewModel.orderDetailsModel?.delegateName ?? "")))
        vc.chatDelegate = self
        push(vc)
    }
    
    func goToComplaints() {
        guard let tabBar = self.tabBarController else { return }

        tabBar.viewControllers?.forEach {
            ($0 as? UINavigationController)?.popToRootViewController(animated: false)
        }
        tabBar.selectedIndex = 3

        if let moreNav = tabBar.viewControllers?[3] as? UINavigationController {
            let vc = ComplaintsVC(viewModel: ComplaintsVM())
            vc.hidesBottomBarWhenPushed = true
            moreNav.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Delegation -

extension OrderDetailsVC : CreateComplaintProtocol ,CancelOrderProtocol, RateOrderProtocol, RejectOrderProtocol, PaymentVCDelegate , ChatDelegateProtocol{
    
    func didTapOnSendButton(title: String, reason: String) {
        viewModel.addNewComplaintsRequest(model: AddComplaintsModel(subject: title, text: reason, orderId: viewModel.orderId, name: nil, phone: nil))
    }
    
    func didTapCancelOrder(reason : String) {
        viewModel.cancelOrder(reason: reason)
    }
    
    func didTapRateOrder(rate: Double, comment: String?) {
        viewModel.rateOrderRequest(rate: rate, comment: comment)
    }
    
    func didTapRejectOrder(reason: String) {
        viewModel.rejectOrderRequest(reason: reason)
    }
    
    func didPaySpecialOrder() {
        viewModel.getOrderDetails()
    }
    
    func didExitChat() {
        viewModel.getOrderDetails()
    }
}

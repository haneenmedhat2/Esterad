//
//  NotificationVC.swift
//  Esterad
//
//  Created by Haneen on 09/12/2025.
//

import UIKit

class NotificationVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    var viewModel : NotificationVM
    let refreshController = UIRefreshControl()
    
    //MARK: - Initializer -
    
    init(viewModel :NotificationVM){
        self.viewModel = viewModel
        super.init(nibName: "NotificationVC", bundle: nil)
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
    
    private func initialConfiguration(){
        self.title = "notifications".localized
        NotificationCountManager.shared.markAllAsRead()
        viewModel.getNotification()
        configureTableView()
        bindToViewModel()
        setupRefreshControl()
    }
    
    func setupRefreshControl(){
        refreshController.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshController
    }

    
    //MARK: - ViewModel binding -
    
    private func bindToViewModel(){
        loading(viewModel.isLoadingPublisher)
        
        viewModel.notificationPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.deleteNotificationPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.showPopup()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Action -
    
    @objc func refreshData(){
        viewModel.resetData()
        viewModel.getNotification()
    }
}

//MARK: - TableView Configutations -

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: NotificationCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.setPlaceholder(isEmpty: viewModel.notificationList.isEmpty , separator: .none, style: .notifications)
        return viewModel.notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: NotificationCell.self, for: indexPath)
        cell.delegate = self
        let item = viewModel.notificationList[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.notificationList[indexPath.row]
        switch item.notificationEnum {
            
        case .delegateFinishedOrder ,.delegateMadeOffer , .delegateRefusedOrder , .delegateRefusedOffer, .delegateUpdateOffer, .userCancelOrder:
            goToOrderDetails(orderId : item.orderId)
            
        case .ticketReply,.ticketInprogress:
            goToComplaintDetails(ticketId : item.ticketId)
            
        case .adminUpdateProfile:
            goToProfile()
            
        case .refundAmount:
            goToWallet()
         
        case .productAvailabilityReply:
            if item.available {
                goToPayment(id: item.productId, price: item.downPaymentPrice)
            } else {
                goToProductDetails(productId :item.productId)
            }
        case .productAvailableAgain:
            goToProductDetails(productId: item.productId)
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.notificationList.count - 1,
           !viewModel.isLastPage {
            viewModel.getNotification()
        }
    }
}

//MARK: - Routes -
extension NotificationVC {
    
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .deleteNotification)
    }
    
    func showDoubleActionPopup(){
        let vc = DoubleActionPopupView()
        vc.delegate = self
        vc.appear(sender: self)
        vc.setupView(type: .deleteNotification)
    }
    
    func goToOrderDetails(orderId : Int){
        let vc = OrderDetailsVC(viewModel: OrderDetailsVM(orderId: orderId))
        push(vc)
    }
    
    func goToComplaintDetails(ticketId : Int){
        let vc = ComplaintDetailsVC(viewModel: ComplaintDetailsVM(complaintId: ticketId))
        push(vc)
    }
    
    func goToProfile(){
        let vc = ProfileVC(viewModel: ProfileVM())
        push(vc)
    }
    
    func goToWallet(){
        let vc = WalletVC(viewModel: WalletVM())
        push(vc)
    }
    
    func goToPayment(id : Int, price : String){
        let vc = PaymentVC(viewModel: PaymentVM(productId: id,productPrice: price,offerId: nil,orderType: .normal))
        push(vc)
    }
    
    func goToProductDetails(productId :Int){
        let vc = ProductDetailsVC(viewModel: ProductDetailsVM(productId: productId))
        push(vc)
    }
}

//MARK: - Protocol Confirmation -

extension NotificationVC : NotificationCellProtocol,DoubleActionPopupProtocol {
    func didTapDelete(notificationId: String) {
        viewModel.notificationId = notificationId
        showDoubleActionPopup()
    }
    func didTapSecondAction() {
        viewModel.deleteNotificationRequest()
    }
}

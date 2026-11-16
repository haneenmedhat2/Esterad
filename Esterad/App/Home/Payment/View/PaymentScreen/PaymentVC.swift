//
//  PaymentVC.swift
//  Esterad
//
//  Created by Haneen on 27/11/2025.
//

import UIKit

class PaymentVC: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    var viewModel : PaymentVMProtocol
    var delegate : PaymentVCDelegate?
    
    //MARK: - Initializer -
    
    init(viewModel : PaymentVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "PaymentVC", bundle: nil)
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
        self.title = "payment".localized
        configureTableView()
        bindViewModel()
        priceLabel.text = viewModel.productPrice + "SAR".localized
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        viewModel.normalPaymentPublisher
            .dropFirst()
            .sinkOnMain { [weak self] response in
                guard let self = self else { return }
                
                // Case 1: Online payment → open WebView
                if let urlString = response?.data?.paytabs?.redirectUrl,
                   let url = URL(string: urlString),
                   !urlString.isEmpty {
                    
                    let paymentVC = PaymentWebViewController()
                    paymentVC.url = url
                    
                    paymentVC.onPaymentAccepted = { [weak self] in
                        self?.showPopup()
                    }
                    let nav = UINavigationController(rootViewController: paymentVC)
                    self.present(nav, animated: true)
                }
                // Case 2: Wallet payment
                else {
                    self.showPopup()
                }
            }
            .store(in: &cancellables)
        
        viewModel.specialPaymentPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                
                // Case 1: Online payment → open WebView
                if let urlString = result?.data?.redirectUrl,
                   let url = URL(string: urlString),
                   !urlString.isEmpty {
                    
                    let paymentVC = PaymentWebViewController()
                    paymentVC.url = url
                    
                    paymentVC.onPaymentAccepted = { [weak self] in
                        self?.showPopup()
                    }
                    let nav = UINavigationController(rootViewController: paymentVC)
                    self.present(nav, animated: true)
                }
                // Case 2: Wallet payment
                else {
                    self.showPopup()
                }
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Action -
    
    @IBAction func didTapConfirmPayment(_ sender: UIButton) {
        guard let paymentType = validatePaymentMethod() else { return }
        viewModel.checkOrderType(paymentType: paymentType)
    }
}

//MARK: - TableView Configuration -
extension PaymentVC : UITableViewDataSource, UITableViewDelegate {
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: PaymentCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.paymentMethodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(with: PaymentCell.self, for: indexPath)
        let item = viewModel.paymentMethodList[indexPath.row]
        let isCellSelected = indexPath == viewModel.indexPath
        cell.setupCell(model: item, isCellSelected: isCellSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.indexPath == indexPath {
            viewModel.indexPath = nil
        } else {
            viewModel.indexPath = indexPath
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "choose_payment_method".localized
        label.font = .myMediumFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

//MARK: - Routes -

extension PaymentVC {
    func showPopup(){
        let vc = LottiePopup()
        vc.onPopupHidden = { [weak self] in
            guard let self = self else { return }
            switch viewModel.orderType {
            case .normal:
                self.goToOrderDetails()

            case .special:
                delegate?.didPaySpecialOrder()
                pop()
            }
        }
        vc.appear(sender: self)
        vc.setupView(type: .payment)
    }

    func goToOrderDetails() {
        guard let tabBar = self.tabBarController else { return }

        if let homeNav = tabBar.viewControllers?.first as? UINavigationController {
                 homeNav.setViewControllers(
                     [homeNav.viewControllers.first].compactMap { $0 },
                     animated: false
                 )
             }
        tabBar.selectedIndex = 1
        guard let ordersNav =
                tabBar.viewControllers?[1] as? UINavigationController
        else { return }

        let detailsVC = OrderDetailsVC( viewModel: OrderDetailsVM(orderId: viewModel.orderId ?? 0))
        detailsVC.hidesBottomBarWhenPushed = true
        ordersNav.pushViewController(detailsVC, animated: false)
    }
}

//MARK: - Validtion -

extension PaymentVC {
    func validatePaymentMethod() -> String?{
        guard let paymentMethod = viewModel.getSelectedPaymentMethod() else {
            show(errorMessage: ValidationError.emptyPaymentMethod.localizedDescription)
            return nil
        }
        return paymentMethod
    }
}

//MARK: - Delegate Protocol -

protocol PaymentVCDelegate: AnyObject {
    func didPaySpecialOrder()
}

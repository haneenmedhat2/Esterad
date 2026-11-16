//
//  WalletVC.swift
//  Esterad
//
//  Created by Haneen on 05/11/2025.
//

import UIKit

class WalletVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var walletBgImage: UIImageView!
    
    //MARK: - Properties -
    
    let viewModel : WalletVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : WalletVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "WalletVC", bundle: nil)
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
    
    func initialConfiguration() {
        self.title = "wallet".localized
        bindViewModel()
        viewModel.showWalletRequest()
        
        if Language.isRTL() {
            walletBgImage.image = UIImage(resource: .walletBackground)
        } else {
            walletBgImage.image = UIImage(resource: .walletBGEng)
        }
    }
    
    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        
        loading(viewModel.isLoadingPublisher)
        
        viewModel.showWalletPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.balanceLabel.text = result?.data?.wallet.toPrice
            }
            .store(in: &cancellables)
        
        viewModel.chargeWalletPublisher
            .sinkOnMain { [weak self] response in
                guard let self = self,
                      let urlString = response?.data?.paytabs.redirectUrl,
                      let url = URL(string: urlString) else { return }
                
                let paymentVC = PaymentWebViewController()
                paymentVC.url = url
                
                paymentVC.onPaymentAccepted = { [weak self] in
                    self?.handlePaymentSuccess()
                }
                
                let nav = UINavigationController(rootViewController: paymentVC)
                self.present(nav, animated: true)
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapWalletRecharge(_ sender: UIButton) {
        goToWalletRecharge()
    }
}
//MARK: - Routes -

extension WalletVC {
    
    func goToWalletRecharge() {
        let walletPop = WalletPopup(viewModel: WalletPopupVM())
        walletPop.delegate = self
        walletPop.appear(sender: self)
    }
    
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .chargeWallet)
    }
    
    func handlePaymentSuccess() {
        print("🎉 Payment completed")
        viewModel.showWalletRequest()
        show(successMessage: "payment_completed_successfully".localized)
    }
}

//MARK: - WalletPopup Delegation -

extension WalletVC : WalletPopupDelegate {
    func didTapOnChargeButton(amount: Double) {
        viewModel.chargeWalletRequest(amount: amount)
    }
}

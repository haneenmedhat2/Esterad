//
//  TermsAndConditionsVC.swift
//  Esterad
//
//  Created by Haneen on 10/11/2025.
//

import UIKit

class TermsAndConditionsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    //MARK: - Properties -
    
    var viewModel : TermsAndConditionsVMProtocol
    weak var chatDelegate: ChatDelegateProtocol?
    
    //MARK: - Initializer -
    
    init(viewModel : TermsAndConditionsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "TermsAndConditionsVC", bundle: nil)
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
        self.title = "terms_and_conditions".localized
        bindViewModel()
        viewModel.termsAndConditionsRequest()
        switch viewModel.model {
        case .register, .more:
            acceptButton.isHidden = true
            buttonView.isHidden = true
        case .order(_, _), .chat(_, _), .companyChat(_, _, _):
            acceptButton.isHidden = false
            buttonView.isHidden = false
        }
    }
    
    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        
        viewModel.termsAndConditionsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                let text = result?.data?.terms ?? ""
                let convertedString = text.htmlToAttributedString
                contentTextView.attributedText = convertedString
            }
            .store(in: &cancellables)
        
        viewModel.actionPublisher
            .sinkOnMain { [weak self] action in
                guard let self, let action else { return }

                switch action {
                case .goToPayment(let id, let price):
                    goToPayment(id : id, price : price)

                case .goToChat(let roomId , let senderName):
                    
                   goToChat(roomId: roomId, senderName: senderName)

                case .goToCompanyChat(let providerId, let senderName, let response):
                    goToCompanyChat(
                        providerId: providerId,
                        senderName: senderName,
                        response: response
                    )
                }
            }
            .store(in: &cancellables)

        error(viewModel.errorPublisher)
    }
    
    //MARK: - Action -
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        viewModel.acceptTapped()
    }
}

//MARK: - Routes -
extension TermsAndConditionsVC {
    
    func goToPayment(id : Int, price : String){
        let vc = PaymentVC(viewModel: PaymentVM(productId: id,productPrice: price,offerId: nil,orderType: .normal))
        push(vc)
    }
    
    func goToChat(roomId : Int , senderName : String){
        UserDefaults.setChatTermsAccepted(roomId: roomId)
        let vc = ChatVC(viewModel: ChatVM(roomId: roomId, senderName: senderName))
        vc.delegate = chatDelegate
        push(vc)
    }

    func goToCompanyChat(
        providerId: Int,
        senderName: String,
        response: BaseResponse<SingleRoomResponse>
    ) {
        guard let roomId = response.data?.room.id else { return }
        UserDefaults.setChatTermsAccepted(roomId: roomId)
        let vc = ChatVC(
            viewModel: ChatVM(
                providerId: providerId,
                senderName: senderName,
                initialResponse: response
            )
        )
        vc.delegate = chatDelegate
        push(vc)
    }
}

//
//  ForgetPasswordVC.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import UIKit

class ForgetPasswordVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var phoneTextField: PhoneTextField!
    
    //MARK: - Properties -
    
    let viewModel : ForgetPasswordVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ForgetPasswordVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ForgetPasswordVC", bundle: nil)
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
        self.title = "Forgot_password".localized
        bindToViewModel()
    }
    
    func bindToViewModel(){
        loading(viewModel.isLoadingPublisher)
        
        viewModel.forgetPasswordPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                self.goToVerification()
            }
            .store(in: &cancellables)
        
        viewModel.validationPublisher
            .compactMap{ $0 }
            .sinkOnMain{ [weak self] error in
                guard let self = self else { return }
                show(errorMessage: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Action -
    
    @IBAction func didTapSend(_ sender: UIButton) {
        let phone = phoneTextField.txtField.text
        let _ = viewModel.validatePhone(phone: phone)
    }
}

//MARK: - Routes -

extension ForgetPasswordVC {
    func goToVerification(){
        guard let phone = phoneTextField.txtField.text else { return }
        let vc = VerificationVC(viewModel: VerificationVM(flow: .changePassword, phoneNumber: phone))
        push(vc)
    }
}

//
//  ChangePhoneVC.swift
//  Esterad
//
//  Created by Haneen on 04/11/2025.
//

import UIKit

class ChangePhoneVC: BaseViewController {
    
    //MARK: - Outlets -

    @IBOutlet weak var phoneTextField: PhoneTextField!
    
    //MARK: - Properties -
    
    let viewModel : ChangePhoneVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ChangePhoneVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ChangePhoneVC", bundle: nil)
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
        self.title = "change_phone_number".localized
        bindToViewModel()
        
        guard var viewControllers = navigationController?.viewControllers else { return }
        viewControllers.removeAll { $0 is VerificationVC }
        navigationController?.viewControllers = viewControllers
    }
    
    //MARK: -  Binding To ViewModel -
    
    func bindToViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.changePhonePublisher
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
    
    @IBAction func didTapChange(_ sender: UIButton) {
         let phone = phoneTextField.txtField.text
        let _ = viewModel.validatePhone(phone: phone)
    }
}

//MARK: - Routes -

extension ChangePhoneVC {
    func goToVerification(){
        guard let phone = phoneTextField.txtField.text else { return }
        let vc = VerificationVC(viewModel: VerificationVM(flow: .activateNewPhone, phoneNumber: phone))
        push(vc)
    }
}

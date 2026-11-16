//
//  ChangePasswordVC.swift
//  Esterad
//
//  Created by Haneen on 04/11/2025.
//

import UIKit

class ChangePasswordVC: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var currentPasswordTextField: PasswordTextField!
    @IBOutlet weak var newPasswordTextField: PasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: PasswordTextField!
    
    //MARK: - Properties -
    
    let viewModel : ChangePasswordVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ChangePasswordVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ChangePasswordVC", bundle: nil)
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
        self.title = "change_password".localized
        bindToViewModel()
    }
    
    func bindToViewModel(){
        loading(viewModel.isLoadingPublisher)
        
        viewModel.changePasswordPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                self.showPopup()
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
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        let currentPassword = currentPasswordTextField.txtField.text
        let newPassword = newPasswordTextField.txtField.text
        let confirmPassword = confirmPasswordTextField.txtField.text
        
        let _ = viewModel.validateUserData(currentPassword: currentPassword, password: newPassword, passwordConfirmation: confirmPassword)
    }
}

//MARK: - Routes -

extension ChangePasswordVC {
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .changePassword)
        vc.onPopupHidden = { [weak self] in
            guard let self = self else { return }
            pop()
        }
    }
}

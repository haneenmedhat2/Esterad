//
//  LoginVC.swift
//  Esterad
//
//  Created by Haneen on 15/10/2025.
//

import UIKit

class LoginVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var phoneTextField: PhoneTextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    
    //MARK: - Properties -
    
    let viewModel : LoginVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : LoginVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "LoginVC", bundle: nil)
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
        setupNavBar()
        bindViewModel()
        requestNotifications()
    }
    
    //MARK: - Navigation Bar Design -
    
    private func setupNavBar(){
        navigationItem.rightBarButtonItem = AppHelper.setupChangeLanguageButton(target: self, action: #selector(didTapChangeLanguage))
        
        navigationItem.leftBarButtonItem = AppHelper.setupAppTitle()
    }

    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.loginPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                guard let result = result else { return }
                if result.key == .needActive {
                    self.goToVerification()
                } else {
                    self.goToHome()
                }
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
    
    private func requestNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
    }
    
    //MARK: - Action -
    
    @IBAction func didTapForgetPassword(_ sender: UIButton) {
        goToForgetPassword()
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        let phone = phoneTextField.txtField.text
        let password = passwordTextField.txtField.text
        let _ = viewModel.validateInputs(phone: phone, password: password)
    }
    
    @IBAction func didTapGuest(_ sender: UIButton) {
        UserDefaults.isLogin = false
        UserDefaults.guest = true
        let vc = AppTabBarController.create()
        AppHelper.changeWindowRoot(vc: vc)
    }
    
    @IBAction func didTapCreateAccount(_ sender: UIButton) {
        goToSignup()
    }
    
    @objc func didTapChangeLanguage() {
        showLanguagePopup()
    }
}

//MARK: - Routes -

extension LoginVC {
    func showLanguagePopup(){
        let vc = LanguagePopUp()
        vc.appear(sender: self)
    }
    
    func goToSignup(){
        let vc = SignupVC(viewModel: SignupVM())
        push(vc)
    }
    
    func goToForgetPassword(){
        let vc = ForgetPasswordVC(viewModel: ForgetPasswordVM())
        push(vc)
    }
    
    func goToHome() {
        UserDefaults.isLogin = true
        UserDefaults.guest = false
        let vc = AppTabBarController.create()
        AppHelper.changeWindowRoot(vc: vc)
    }
    
    func goToVerification(){
        guard let phone = phoneTextField.txtField.text else { return }
        let vc = VerificationVC(viewModel: VerificationVM(flow: .signup, phoneNumber: phone))
        push(vc)
    }
}

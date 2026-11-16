//
//  SignupVC.swift
//  Esterad
//
//  Created by Haneen on 18/10/2025.
//

import UIKit

class SignupVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: GeneralTextField!
    @IBOutlet weak var phoneTextField: PhoneTextField!
    @IBOutlet weak var emailTextField: GeneralTextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: PasswordTextField!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var confirmBtn: MainButton!
    
    //MARK: - Properties -
    
    var viewModel : SignupVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : SignupVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "SignupVC", bundle: nil)
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
        confirmBtn.backgroundColor = .lightGray
        setupNavBar()
        configureProfileImage()
        bindViewModel()
    }
    
    //MARK: - Navigation Bar Setup -
    
    private func setupNavBar(){
        navigationItem.rightBarButtonItem = AppHelper.setupChangeLanguageButton(target: self, action: #selector(didTapChangeLanguage))
        navigationItem.leftBarButtonItem = AppHelper.setupAppTitle()
    }
    
    //MARK: - View Configurations -
    
    private func configureProfileImage() {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCameraTap))
        profileImage.addGestureRecognizer(tap)
    }
    
    func addDashedBorder(to imageView: UIImageView) {
        imageView.layer.sublayers?.removeAll(where: { $0.name == "DashedBorder" })
        
        let dashedBorder = CAShapeLayer()
        dashedBorder.name = "DashedBorder"
        dashedBorder.strokeColor = UIColor.main.cgColor
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.fillColor = nil
        dashedBorder.lineWidth = 3
        
        let cornerRadius = imageView.layer.cornerRadius
        dashedBorder.path = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: cornerRadius).cgPath
        dashedBorder.frame = imageView.bounds
        
        imageView.layer.addSublayer(dashedBorder)
    }
    
    //MARK: - CheckBox Button  -
        
    private func updateCheckboxAppearance() {
        viewModel.isChecked.toggle()
        if viewModel.isChecked {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            confirmBtn.isEnabled = true
            confirmBtn.backgroundColor = .main

        } else {
            checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
            confirmBtn.isEnabled = false
            confirmBtn.backgroundColor = .lightGray
        }
    }
    
    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        
        loading(viewModel.isLoadingPublisher)
        
        viewModel.signupPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                goToVerification()
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
    
    @IBAction func didTapCheckBox(_ sender: UIButton) {
        updateCheckboxAppearance()
    }
    
    @IBAction func didTapTermsAndConditions(_ sender: UIButton) {
        goToTermsAndConditions()
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        goToLogin()
    }
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        let _ = viewModel.validateUserData(username: usernameTextField.txtField.text, phone: phoneTextField.txtField.text, email: emailTextField.txtField.text, password: passwordTextField.txtField.text, confirmPassword: confirmPasswordTextField.txtField.text)
    }
    
    @objc func didTapChangeLanguage() {
        showLanguagePopup()
    }
    
    @objc func onCameraTap(){
        let picker = ImagePicker()
        picker.pickImage { [weak self] image, imageData in
            guard let self = self else { return }
            self.profileImage.image = image
            viewModel.image = imageData ?? Data()
            self.addDashedBorder( to: profileImage)
        }
    }
}

//MARK: - Routes -

extension SignupVC {
    func showLanguagePopup(){
        let vc = LanguagePopUp()
        vc.appear(sender: self)
    }
    
    func goToLogin(){
        popToRoot()
    }
    
    func goToVerification(){
        guard let phone = phoneTextField.txtField.text else { return }
        let vc = VerificationVC(viewModel: VerificationVM(flow: .signup, phoneNumber: phone))
        push(vc)
    }
    
    func goToTermsAndConditions(){
        let vc = TermsAndConditionsVC(viewModel: TermsAndConditionsVM(model: .register))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
}

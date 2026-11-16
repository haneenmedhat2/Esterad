//
//  SettingsVC.swift
//  Esterad
//
//  Created by Haneen on 03/11/2025.
//

import UIKit


class SettingsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    let viewModel :SettingsVM
    
    //MARK: - Initializer -
    
    init(viewModel :SettingsVM ){
        self.viewModel = viewModel
        super.init(nibName: "SettingsVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: - Initial Setup -
    
    func initialSetup() {
        self.title = "settings".localized
        configureTableView()
        bindToViewModel()
    }
    
    //MARK: -  Binding To ViewModel -
    
    func bindToViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.changeLanguagePublisher
            .dropFirst()
            .sinkOnMain{ result in
                UserDefaults.user = result?.data
            }
            .store(in: &cancellables)
        
        viewModel.sendCurrentPhoneCodePublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                self.goToVerification()
            }
            .store(in: &cancellables)
        
        viewModel.switchNotificationPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "")
                UserDefaults.isNotify = result?.data?.notify ?? true
            }
            .store(in: &cancellables)
        
        viewModel.deleteAccountPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "")
                self.goToLogin()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}

//MARK: - TableView Configuration -

extension SettingsVC : UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MoreCell.self, bundle: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MoreCell.self, for: indexPath)
        let item = viewModel.settingsItems[indexPath.row]
        cell.delegate = self
        cell.setupCell(model: item, isSwitchEnabled: UserDefaults.isNotify)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.settingsItems[indexPath.row]
        switch item {
        case .changephone:
            viewModel.sendCurrentPhoneCodeRequest()
        case .changeLanguage:
            showLanguagwPopup()
        case .changePassword:
           goToChangePassword()
        case .deleteAccount:
            showDoubleActionPopup()
        default:
            break
        }
    }
}

//MARK: - Routes -

extension SettingsVC {
    
    func goToVerification(){
        let vc = VerificationVC(viewModel : VerificationVM(flow: .activateCurrentPhone, phoneNumber: UserDefaults.user?.phone ?? ""))
        push(vc, animated: true)
    }
    
    func showLanguagwPopup(){
        let vc = LanguagePopUp(isFirstTime: false)
        vc.appear(sender: self)
    }
    
    func showDoubleActionPopup(){
        let vc = DoubleActionPopupView()
        vc.delegate = self
        vc.appear(sender: self)
        vc.setupView(type: .deleteAccount)
    }
    
    func goToLogin(){
        UserDefaults.isLogin = false
        UserDefaults.guest = true
        Session.user = nil
        Session.token = nil
        UserDefaults.isNotify = true
        
        let loginVC = LoginVC(viewModel: LoginVM())
        let nav = BaseNav(rootViewController: loginVC)
        AppHelper.changeWindowRoot(vc: nav)
    }

    func goToChangePassword(){
        let vc = ChangePasswordVC(viewModel: ChangePasswordVM())
        push(vc)
    }
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .changePassword)
    }
}

//MARK: - Settings Cell Delegation -

extension SettingsVC : MoreCellProtocol {
    func didTapSwitch() {
     viewModel.switchNotificationRequest()
    }
}

//MARK: - Double Action Popup  Delegation  -

extension SettingsVC : DoubleActionPopupProtocol {
    func didTapSecondAction() {
        viewModel.deleteAccountRequest()
    }
}

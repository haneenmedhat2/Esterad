//
//  VerificationVC.swift
//  Esterad
//
//  Created by Haneen on 19/10/2025.
//

import UIKit
import CoreLocation

class VerificationVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var OTPField: OTPTextField!
    @IBOutlet weak var resendCodeBtn: UnderlinedButton!
    
    //MARK: - Properties -
    
    var viewModel : VerificationVMProtocol
    var locationManager: CLLocationManager?

    //MARK: - Initializer -
    
    init(viewModel : VerificationVMProtocol, ){
        self.viewModel = viewModel
        super.init(nibName: "VerificationVC", bundle: nil)
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
        self.title = "verification_code".localized
        generateHiddenNumber()
        OTPField.configure(with: 4)
        bindViewModel()
        viewModel.startCountdown()
    }
    
    func generateHiddenNumber(){
        let maskedNumber: String
        let lastTwo = viewModel.phoneNumber.suffix(2)
        maskedNumber = String(repeating: "*", count: viewModel.phoneNumber.count - 2) + lastTwo
        let ltrMaskedNumber = "\u{202A}\(maskedNumber)\u{202C}"
        titleLabel.text = "enter_sent_code".localized + " \(ltrMaskedNumber)"
    }

    //MARK: - View Model Binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.verificationPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                Session.user = result?.data?.user
                Session.token = result?.data?.token
                self.handleSendAction()
            }
            .store(in: &cancellables)
        
        viewModel.remainingTimePublisher
            .sinkOnMain{ [weak self] time in
                guard let self = self else { return }
                self.timerLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
            }
            .store(in: &cancellables)
        
        viewModel.validationPublisher
            .compactMap{ $0 }
            .sinkOnMain{ [weak self] error in
                guard let self = self else { return }
                show(errorMessage: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.isResendEnabledPublisher
            .sinkOnMain{ [weak self] isEnabled in
                guard let self = self else { return }
                self.resendCodeBtn.isEnabled = isEnabled
                self.resendCodeBtn.setTitleColor(isEnabled ? .main : .lightGray, for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.resendCodePublisher
            .dropFirst()
            .sinkOnMain{ [weak self] _ in
                guard let self = self else { return }
                viewModel.startCountdown()
            }
            .store(in: &cancellables)
        
        viewModel.resendCurrentPhoneCodePublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                viewModel.startCountdown()
            }
            .store(in: &cancellables)

        viewModel.currentPhoneActivationPublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                self.handleSendAction()
            }
            .store(in: &cancellables)
        
        viewModel.resendChangePhoneCodePublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                viewModel.startCountdown()
            }
            .store(in: &cancellables)
        
        viewModel.changePhoneActivationPublisher
            
            .compactMap({$0})
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                Session.user = result.data?.user
                Session.token = result.data?.token
                self.handleSendAction()
            }
            .store(in: &cancellables)
        
        viewModel.updateLocationPublisher
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                UserDefaults.isLogin = true
                UserDefaults.guest = false
                self.goToHome()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    private func handleSendAction() {
        switch viewModel.flow {
        case .signup:
            self.requestUserLocation()
        case .changePassword:
            goToResetPassword()
        case .activateCurrentPhone:
            goToChangePhone()
        case .activateNewPhone:
            showPopup()
        }
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        let _ = viewModel.validateOTP(otp: OTPField.text)
    }
    
    @IBAction func didTapResendCode(_ sender: UIButton) {
        viewModel.handleResendCode()
    }
}

//MARK: - Routes -

extension VerificationVC {
    
    func goToResetPassword() {
        let vc = ResetPasswordVC(viewModel: ResetPasswordVM(phone: viewModel.phoneNumber))
        push(vc)
    }
    
    func goToHome() {
        let vc = AppTabBarController.create()
        AppHelper.changeWindowRoot(vc: vc)
    }
    
    func goToChangePhone(){
        let vc = ChangePhoneVC(viewModel: ChangePhoneVM())
        push(vc)
    }
    
    func showPopup(){
        let vc = LottiePopup()
        vc.onPopupHidden = { [weak self] in
            guard let self = self else { return }
            if let settingsVC = navigationController?.viewControllers.first(where: { $0 is SettingsVC }) {
                navigationController?.popToViewController(settingsVC, animated: true)
            }
        }
        vc.appear(sender: self)
        vc.setupView(type: .changePhone)
    }
}

//MARK: - Curent Location Handling -

extension VerificationVC: CLLocationManagerDelegate {
    
    private func requestUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            handleDefaultLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager?.requestLocation()
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager?.requestLocation()
        case .denied, .restricted:
            handleDefaultLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        reverseGeocode(coordinate: location.coordinate)
    }
    
    private func handleDefaultLocation() {
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
        reverseGeocode(coordinate: defaultCoordinate)
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        AppHelper.getAddressFromCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude) { [weak self] address in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.viewModel.updateLocation(model: UpdateLocationModel(lat: coordinate.latitude, long: coordinate.longitude, address: address))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleDefaultLocation()
    }
}

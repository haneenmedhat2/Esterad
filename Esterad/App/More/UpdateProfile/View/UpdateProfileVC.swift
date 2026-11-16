//
//  UpdateProfileVC.swift
//  Esterad
//
//  Created by Haneen on 03/11/2025.
//

import UIKit

class UpdateProfileVC: BaseViewController {
    
    //MARK: - Outlets -

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: GeneralTextField!
    @IBOutlet weak var emailTextField: GeneralTextField!
    
    //MARK: - Properties -
    
    var viewModel : UpdateProfileVM

    //MARK: - Initializer -
    
    init(viewModel : UpdateProfileVM){
        self.viewModel = viewModel
        super.init(nibName: "UpdateProfileVC", bundle: nil)
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
    
    private func initialConfiguration(){
        self.title = "edit_profile".localized
        configureProfileImage()
        setupUserData()
        bindViewModel()
    }
    
    private func configureProfileImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCameraTap))
        profileImage.addGestureRecognizer(tap)

        let overlayImageView = UIImageView(image: UIImage(resource: .profilePic))
        overlayImageView.frame = profileImage.bounds
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.alpha = 0.8
        overlayImageView.isUserInteractionEnabled = false

        profileImage.addSubview(overlayImageView)
        addDashedBorder( to: profileImage )
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
        
    private func setupUserData(){
        guard let user = UserDefaults.user else { return }
        emailTextField.txtField.text = user.email
        usernameTextField.txtField.text = user.name ?? ""
        profileImage.kf.setImage(with: URL(string: user.avatar ?? ""),placeholder: UIImage(resource: .profilePic), options: [.onFailureImage(UIImage(resource: .profilePic))])
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.updateProfilePublisher
            .dropFirst()
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "")
                popToRoot()
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
    
    //MARK: - Actions -
    
    @IBAction func didTapConfirmUpdate(_ sender: UIButton) {
        let username = usernameTextField.txtField.text
        let email = emailTextField.txtField.text
        
        let _ = viewModel.validateUserData(username: username, email: email)
    }
    
    @objc func onCameraTap(){
        let picker = ImagePicker()
        picker.pickImage { [weak self] image, imageData in
            guard let self = self else { return }
            self.profileImage.image = image
            viewModel.image = imageData ?? Data()
        }
    }
}

//
//  ContactUsVC.swift
//  Esterad
//
//  Created by Haneen on 09/11/2025.
//

import UIKit

class ContactUsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var usernameTextField: GeneralTextField!
    @IBOutlet weak var phoneTextField: PhoneTextField!
    @IBOutlet weak var messageTitleTextField: GeneralTextField!
    @IBOutlet weak var messageBodyTextView: DropDownTextView!
    @IBOutlet weak var collectionView: CollectionViewContentSized!
    
    //MARK: - Properties -
    
    let viewModel : ContactUsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ContactUsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ContactUsVC", bundle: nil)
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
        self.title = "contact_us".localized
        configureUIForUserMode()
        bindViewModel()
        viewModel.socialRequest()
        configureCollectionView()
    }
    
     func configureUIForUserMode() {
        switch UserMode.current {
        case .authenticated:
            usernameTextField.isHidden = true
            phoneTextField.isHidden = true
            
        case .guest:
            usernameTextField.isHidden = false
            phoneTextField.isHidden = false
        }
    }

    //MARK: - Action -

    @IBAction func didTapSend(_ sender: UIButton) {
        let name = usernameTextField.txtField.text
        let phone = phoneTextField.txtField.text
        let title = messageTitleTextField.txtField.text
        let message = messageBodyTextView.textView.text
        let _ = viewModel.validateInputs(model: ContactUsModel(name: name, phone: phone, message: message, title: title))
    }
    
    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        
        loading(viewModel.isLoadingPublisher)
        
        viewModel.socialPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.contactUsPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                show(successMessage: result?.message ?? "")
                pop()
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
}

//MARK: - Collection View -
extension ContactUsVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: SocialCell.self, bundle: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.socialList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: SocialCell.self, for: indexPath)
        let item = viewModel.socialList[indexPath.row]
        cell.setupCell(image: item.image ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.socialList[indexPath.row]
        AppHelper.openUrl(item.link)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 40 * viewModel.socialList.count
        let totalSpacingWidth = 10 * (viewModel.socialList.count - 1)
        
        let totalContentWidth = totalCellWidth + totalSpacingWidth
        let inset = max((collectionView.frame.width - CGFloat(totalContentWidth)) / 2, 0)
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

}

//
//  GuestComplaintVC.swift
//  Esterad
//
//  Created by Haneen on 16/12/2025.
//

import UIKit
import Combine

class GuestComplaintVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var phoneTextField: PhoneTextField!
    @IBOutlet weak var usernameTextField: GeneralTextField!
    @IBOutlet weak var complaintTitleTextField: GeneralTextField!
    @IBOutlet weak var complaintReasonTextField: DropDownTextView!
    
    //MARK: - Properties -
    
    let viewModel : GuestComplaintVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : GuestComplaintVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "GuestComplaintVC", bundle: nil)
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
        self.title = "add_complaint".localized
        bindViewModel()
    }

    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.addNewComplaintPublisher
            .compactMap { $0 }
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                show(successMessage: result.message )
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
    
    
    //MARK: - Action -
    
    @IBAction func didTapSend(_ sender: UIButton) {
        let phone = phoneTextField.txtField.text
        let name = usernameTextField.txtField.text
        let subject = complaintTitleTextField.txtField.text
        let reason = complaintReasonTextField.textView.text
        let _ = viewModel.validateUserData(model: AddComplaintsModel(subject: subject, text: reason, orderId: nil, name: name, phone: phone))
    }
}

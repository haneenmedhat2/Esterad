//
//  ComplaintDetailsVC.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import UIKit

class ComplaintDetailsVC: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var complaintNum: UILabel!
    @IBOutlet weak var complaintDetailsView: UIView!
    @IBOutlet weak var complaintReasonView: UIView!
    @IBOutlet weak var adminResponseView: UIView!
    @IBOutlet weak var complaintTitle: UILabel!
    @IBOutlet weak var complaintStatus: UILabel!
    @IBOutlet weak var complaintDate: UILabel!
    @IBOutlet weak var complaintReasonLabel: UILabel!
    @IBOutlet weak var adminResponseLabel: UILabel!
    
    //MARK: - Properties -
    
    let viewModel : ComplaintDetailsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ComplaintDetailsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ComplaintDetailsVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initialConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(isComplaintsChanged), name: .isComplaintsChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .isComplaintsChanged, object: nil)
    }
    
    //MARK: - Initial Setup -
    
    func initialConfiguration() {
        self.title = "complaint_details".localized
        view.isHidden = true
        bindViewModel()
        viewModel.complaintsDetailsRequest()
    }
    
    func setupData(model : ComplaintsDetails){
        complaintNum.text = "#\(model.id ?? 0)"
        complaintTitle.text = model.subject
        complaintStatus.text = model.statusText
        complaintDate.text = model.createdAt
        complaintReasonLabel.text = model.text
        
        if let reply = model.reply, !reply.trimWhiteSpace().isEmpty {
            adminResponseView.isHidden = false
            adminResponseLabel.text = reply
        } else {
            adminResponseView.isHidden = true
        }
    }
    
    //MARK: - ViewModel Binding -

    private func bindViewModel() {
        
        viewModel.complaintDetailsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                guard let response = result?.data?.ticket else { return }
                view.isHidden = false
                setupData(model : response)
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @objc func isComplaintsChanged(){
        viewModel.complaintsDetailsRequest()
    }
}

//
//  ComplaintsVC.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import UIKit

class ComplaintsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addnewComplaintsBtn: IconTextGeneralButton!
    
    //MARK: - Properties -
    
    let viewModel : ComplaintsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : ComplaintsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ComplaintsVC", bundle: nil)
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
        self.title = "complaints_and_suggestions".localized
        bindViewModel()
        viewModel.getComplaintsRequest()
        configureTableView()
        
        addnewComplaintsBtn.onTap = { [weak self] in
            guard let self = self else { return}
            self.showCreateComplaint()
        }
    }
    
    //MARK: - ViewModel Binding -

    private func bindViewModel() {
        
        viewModel.complaintPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.addNewComplaintPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.showPopup()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}

//MARK: - Tableview configuration -

extension ComplaintsVC : UITableViewDataSource,UITableViewDelegate{
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ComplaintsCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.setPlaceholder(isEmpty: viewModel.complaintsList.isEmpty , separator: .none, style: .emptyComplaints)
        return viewModel.complaintsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ComplaintsCell.self, for: indexPath)
        let item = viewModel.complaintsList[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.complaintsList[indexPath.row]
        goToComplaintDetails(id : item.id ?? 0)
    }
}

//MARK: - Routes -

extension ComplaintsVC {
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .createComplaint)
    }
    
    func goToComplaintDetails(id : Int){
        let vc = ComplaintDetailsVC(viewModel: ComplaintDetailsVM(complaintId: id))
        push(vc)
    }
    
    func showCreateComplaint(){
        let vc = CreateComplaintPopup()
        vc.delegate = self
        vc.appear(sender: self)
    }
}

//MARK: - Delegation -

extension ComplaintsVC : CreateComplaintProtocol {
    func didTapOnSendButton(title: String, reason: String) {
        viewModel.addNewComplaintsRequest(model: AddComplaintsModel(subject: title, text: reason, orderId: nil ,name: nil , phone: nil))
    }
}

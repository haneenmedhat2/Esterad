//
//  OrderTypeVC.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import UIKit

class OrderTypeVC: BaseViewController {

    //MARK: - Outlets -

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var tableView: TableViewContentSized!
    @IBOutlet weak var orderStateView: OrderStateView!
    
    //MARK: - Properties -
    
    var viewModel : OrderTypeVMProtocol
    private let refreshControl = UIRefreshControl()

    //MARK: - Initializer -
    
    init(viewModel :OrderTypeVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "OrderTypeVC", bundle: nil)
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
        bindViewModel()
        viewSetup()
        self.title = viewModel.type.stringValue.localized
        configureTableView()
        orderStateView.getCollectionViewDataSource(collectionArray: viewModel.orderStatusList)
        viewModel.getOrders()
        orderStateView.delegate = self
        setupRefreshControl()
    }
    
    func viewSetup(){
        orderStateView.layer.cornerRadius = 16
        orderStateView.layer.borderColor = UIColor.textFieldBorder.cgColor
        orderStateView.layer.borderWidth = 1
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //MARK: - ViewModel binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        viewModel.orderPublisher
            .sinkOnMain { [weak self] user in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
  
    //MARK: - Action -

    @objc private func refreshData() {
        viewModel.resetData()
        viewModel.getOrders()
    }
}

//MARK: - TableView Configutations -

extension OrderTypeVC : UITableViewDelegate , UITableViewDataSource {
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: OrderCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.setPlaceholder(isEmpty: viewModel.ordersList.isEmpty , separator: .none, style: .emptyOrder)
        return viewModel.ordersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: OrderCell.self, for: indexPath)
        let item = viewModel.ordersList[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.ordersList[indexPath.row]
        let vc = OrderDetailsVC(viewModel: OrderDetailsVM(orderId: item.id ?? 0))
        push(vc)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.ordersList.count - 1,
           !viewModel.isLastPage {
            viewModel.getOrders()
        }
    }
}

//MARK: - StateView Delegation -

extension OrderTypeVC : OrderStateViewDelegate {
    func didSelectItem(at orderStatus: OrderStatus) {
        viewModel.status = orderStatus.apiValue
        viewModel.resetData()
        viewModel.getOrders()
    }
}

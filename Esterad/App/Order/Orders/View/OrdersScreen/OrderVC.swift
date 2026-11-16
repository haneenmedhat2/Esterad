//
//  OrderVC.swift
//  Esterad
//
//  Created by Haneen on 15/10/2025.
//

import UIKit

class OrderVC: BaseViewController {

    //MARK: - Outlets -

    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    let viewModel : OrderVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel :OrderVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "OrderVC", bundle: nil)
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
        self.title = "orders".localized
        configureTableView()
        setupNotificationButton()
    }
}

//MARK: - TableView Configutations -

extension OrderVC : UITableViewDelegate , UITableViewDataSource {
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: OrderTypeCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orderTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: OrderTypeCell.self, for: indexPath)
        let item = viewModel.orderTypes[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.orderTypes[indexPath.row]
        let vc = OrderTypeVC(viewModel: OrderTypeVM(type: item))
        vc.hidesBottomBarWhenPushed = true 
        push(vc)
    }
}

//MARK: - Routes -

extension OrderVC {
    func goToNotification(){
      let vc = NotificationVC(viewModel: NotificationVM())
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
}

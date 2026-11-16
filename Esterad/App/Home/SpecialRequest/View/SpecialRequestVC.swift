//
//  SpecialRequestVC.swift
//  Esterad
//
//  Created by Haneen on 25/11/2025.
//

import UIKit

class SpecialRequestVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var productTypeTextField: GeneralTextField!
    @IBOutlet weak var specificationsTextView: DropDownTextView!
    @IBOutlet weak var requiredQuantityTextField: GeneralTextField!
    @IBOutlet weak var expectedBudgetTextField: GeneralTextField!
    @IBOutlet weak var notesTextView: DropDownTextView!
    
    //MARK: - Properties -
    
    var viewModel : SpecialRequestVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : SpecialRequestVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "SpecialRequestVC", bundle: nil)
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
        self.title = "special_request".localized
        bindViewModel()
        viewModel.getPlaceHolder()
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        viewModel.specialRequestPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.showPopup()
            }
            .store(in: &cancellables)
        
        viewModel.placeholderPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                notesTextView.placeholderLabel.text = result?.data?.placeholder
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Action -
    
    @IBAction func didTapSend(_ sender: UIButton) {
        
        guard let productType = validateProductType() else { return }
        guard let productDesc = validateSpecifications() else { return }
        guard let productQty = validateRequiredQuantity() else { return }
        let expectedBudget = validateExpectedBudget()
        let notes = validateNotes()

        let model = SpecialRequestModel(delegateId: viewModel.delegateId, categoryId: viewModel.categoryId, type: OrderType.special.apiValue, productType: productType, productDesc: productDesc, productQty: productQty, expectedBudget: expectedBudget, notes: notes)
        viewModel.createSpecialOrder(model: model )
    }
}

//MARK: - Validation -
extension SpecialRequestVC {
    
    func validateProductType() -> String? {
        guard let productType = productTypeTextField.txtField.text , !productType.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptyProductType.localizedDescription)
            return nil
        }
        return productType
    }
    
    func validateSpecifications() -> String? {
        guard let specifications = specificationsTextView.textView.text , !specifications.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptySpecifications.localizedDescription)
            return nil
        }
        return specifications
    }
    
    func validateRequiredQuantity() -> Int? {
        guard let requiredQuantity = requiredQuantityTextField.txtField.text , !requiredQuantity.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptyRequiredQuantity.localizedDescription)
            return nil
        }
        
        return Int(requiredQuantity)
    }
    
    func validateExpectedBudget() -> Double? {
        guard let expectedBudget = expectedBudgetTextField.txtField.text , !expectedBudget.trimWhiteSpace().isEmpty else {
            return nil
        }
        
        return Double(expectedBudget)
    }
    
    func validateNotes() -> String? {
        guard let notes = notesTextView.textView.text , !notes.trimWhiteSpace().isEmpty else {
            return nil
        }
        return notes
    }
}

//MARK: - Routes -

extension SpecialRequestVC {
    func showPopup(){
        let vc = LottiePopup()
        vc.appear(sender: self)
        vc.setupView(type: .createOrder)
        vc.onPopupHidden = { [weak self] in
            guard let self = self else { return }
            self.goToOrderDetails()
        }
    }
    
    func goToOrderDetails() {
        guard let tabBar = self.tabBarController else { return }

        if let homeNav = tabBar.viewControllers?.first as? UINavigationController {
                 homeNav.setViewControllers(
                     [homeNav.viewControllers.first].compactMap { $0 },
                     animated: false
                 )
             }
        tabBar.selectedIndex = 1
        guard let ordersNav =
                tabBar.viewControllers?[1] as? UINavigationController
        else { return }

        let detailsVC = OrderDetailsVC( viewModel: OrderDetailsVM(orderId: viewModel.orderId))
        detailsVC.hidesBottomBarWhenPushed = true
        ordersNav.pushViewController(detailsVC, animated: false)
    }
}


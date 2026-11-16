//
//  FilterPopup.swift
//  Esterad
//
//  Created by Haneen on 17/11/2025.
//

import UIKit

class FilterPopup: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var CountryPickerField: PickerFieldView!
    @IBOutlet weak var carBrandPickerField: PickerFieldView!
    @IBOutlet weak var carTypePickerField: PickerFieldView!
    @IBOutlet weak var engineCapacityField: GeneralTextField!
    @IBOutlet weak var carModelPickerField: PickerFieldView!
    @IBOutlet weak var statusPickerField: PickerFieldView!
    @IBOutlet weak var gearTypePickerField: PickerFieldView!
    @IBOutlet weak var fuelTypePickerField: PickerFieldView!
    @IBOutlet weak var mainCategoryPickerField: PickerFieldView!
    @IBOutlet weak var tableView: TableViewContentSized!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingRadioBtn: RadioButton!
    
    //MARK: - Properties -
    
    var viewModel : CategoryDetailsVMProtocol
    let category : Category
    let isProduct: Bool
    var model : SubcategoriesModel
    var carTypeId : Int?
    var selectedIndex : IndexPath?
    var delegate : FilterPopupDelegate?
    var isPresentingPopup: Bool = false
    
    //MARK: - Initializer  -
    
    init(viewModel : CategoryDetailsVMProtocol, category : Category, isProduct: Bool , model : SubcategoriesModel ) {
        self.viewModel = viewModel
        self.category = category
        self.isProduct = isProduct
        self.model = model
        super.init(nibName: "FilterPopup", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldSetGradientBackground = false
        configView()
        bindViewModel()
        configureTableView()
        handleViewAppearance()
        setInitialValues()
    }
    
    //MARK: - View Configuration -
    
    func configView(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor  = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
        contentView.isUserInteractionEnabled = true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackViewTapped))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        let rateBtnTap = UITapGestureRecognizer(target: self, action: #selector(onRateBtnTapped))
        ratingStackView.isUserInteractionEnabled = true
        ratingStackView.addGestureRecognizer(rateBtnTap)
        
        
        CountryPickerField.pickerType = .importedCountry
        CountryPickerField.delegate = self
        
        carBrandPickerField.pickerType = .carBrand
        carBrandPickerField.delegate = self
        
        carTypePickerField.pickerType = .carType
        carTypePickerField.delegate = self
        
        carModelPickerField.pickerType = .carModel
        carModelPickerField.delegate = self
        
        statusPickerField.pickerType = .state
        statusPickerField.delegate = self
        
        gearTypePickerField.pickerType = .transmissionType
        gearTypePickerField.delegate = self
        
        fuelTypePickerField.pickerType = .fuelType
        fuelTypePickerField.delegate = self
        
        mainCategoryPickerField.pickerType = .mainCategory
        mainCategoryPickerField.delegate = self
    }
    
    func handleViewAppearance(){
        switch category.categoryKind {
        case .car,.spareParts:
            if isProduct {
                mainCategoryPickerField.isHidden = true
                tableView.isHidden = true
                ratingStackView.isHidden = true
                
            } else {
                CountryPickerField.isHidden =  true
                carBrandPickerField.isHidden = true
                carTypePickerField.isHidden = true
                engineCapacityField.isHidden = true
                carModelPickerField.isHidden = true
                statusPickerField.isHidden = true
                gearTypePickerField.isHidden = true
                fuelTypePickerField.isHidden = true
                mainCategoryPickerField.isHidden = true
                tableView.isHidden = true
            }
        case .furniture,.other:
            if isProduct {
                carBrandPickerField.isHidden = true
                carTypePickerField.isHidden = true
                engineCapacityField.isHidden = true
                carModelPickerField.isHidden = true
                statusPickerField.isHidden = true
                gearTypePickerField.isHidden = true
                fuelTypePickerField.isHidden = true
                ratingStackView.isHidden = true
                
            } else {
                CountryPickerField.isHidden =  true
                carBrandPickerField.isHidden = true
                carTypePickerField.isHidden = true
                engineCapacityField.isHidden = true
                carModelPickerField.isHidden = true
                statusPickerField.isHidden = true
                gearTypePickerField.isHidden = true
                fuelTypePickerField.isHidden = true
                mainCategoryPickerField.isHidden = true
                tableView.isHidden = true
            }
        }
    }
    
    private func setInitialValues() {
        if let status = model.status, let item = viewModel.stateList.first(where: { $0.apiValue == status }) {
            statusPickerField.txtField.text = item.name
        }
        if let transmission = model.transmission, let item = viewModel.transmissionList.first(where: { $0.apiValue == transmission }) {
            gearTypePickerField.txtField.text = item.name
        }
        if let fuelType = model.fuelType, let item = viewModel.fuelTypeList.first(where: { $0.apiValue == fuelType }) {
            fuelTypePickerField.txtField.text = item.name
        }
        
        if model.importingCountryId != nil {
            viewModel.getImportingCountries()
        }
        if model.carCompanyId != nil {
            viewModel.getCarCompanies()
        }
        if model.carTypeId != nil {
            viewModel.getCarType()
        }
        if model.carModelId != nil && carTypeId != nil {
            viewModel.getCarModel(carTypeId: carTypeId!)
        }
        if model.mainSectionId != nil {
            viewModel.getMainSections()
        }
        if model.rate != nil {
            ratingRadioBtn.isOn = true
        }
    }
    
    func appear(sender:UIViewController){
        sender.present(self, animated: false){
            self.show()
        }
    }
    
    func show(){
        UIView.animate(withDuration: 1, delay: 0.1){
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                
            }
            self.removeFromParent()
        }
    }
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.importingCountriesPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                if self.isPresentingPopup {
                    let selectedItem = self.viewModel.importingCountriesList.first(where: { $0.id == self.model.importingCountryId })
                    self.presentBasicList(title: "country".localized, list: self.viewModel.importingCountriesList, selectedItem: selectedItem) { selected in
                        if let selected = selected {
                            self.CountryPickerField.txtField.text = selected.name
                            self.model.importingCountryId = selected.id
                        } else {
                            self.CountryPickerField.txtField.text = ""
                            self.model.importingCountryId = nil
                        }
                    }
                } else {
                    if let selectedItem = self.viewModel.importingCountriesList.first(where: { $0.id == self.model.importingCountryId }) {
                        self.CountryPickerField.txtField.text = selectedItem.name
                    }
                }
                self.isPresentingPopup = false
            }
            .store(in: &cancellables)
        
        viewModel.carCompaniesPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                if self.isPresentingPopup {
                    let selectedItem = self.viewModel.carCompaniesList.first(where: { $0.id == self.model.carCompanyId })
                    self.presentBasicList(title: "car_brand".localized, list: self.viewModel.carCompaniesList, selectedItem: selectedItem) { selected in
                        if let selected = selected {
                            self.carBrandPickerField.txtField.text = selected.name
                            self.model.carCompanyId = selected.id
                        } else {
                            self.carBrandPickerField.txtField.text = ""
                            self.model.carCompanyId = nil
                        }
                    }
                } else {
                    if let selectedItem = self.viewModel.carCompaniesList.first(where: { $0.id == self.model.carCompanyId }) {
                        self.carBrandPickerField.txtField.text = selectedItem.name
                    }
                }
                self.isPresentingPopup = false
            }
            .store(in: &cancellables)
        viewModel.carTypePublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }

                if self.isPresentingPopup {
                    let selectedItem = self.viewModel.carTypeList.first(where: { $0.id == self.model.carTypeId })

                    self.presentBasicList(
                        title: "car_type".localized,
                        list: self.viewModel.carTypeList,
                        selectedItem: selectedItem
                    ) { selected in
                        guard let selected = selected else {
                            self.carTypePickerField.txtField.text = ""
                            self.carTypeId = nil
                            self.model.carTypeId = nil
                            self.carModelPickerField.txtField.text = ""
                            self.model.carModelId = nil
                            return
                        }
                        self.carTypePickerField.txtField.text = selected.name
                        self.carTypeId = selected.id ?? 0
                        self.model.carTypeId = selected.id
                        self.carModelPickerField.txtField.text = ""
                        self.model.carModelId = nil

                    }
                } else {
                    if let selectedItem = self.viewModel.carTypeList.first(where: { $0.id == self.model.carTypeId }) {
                        self.carTypePickerField.txtField.text = selectedItem.name
                    }
                }

                self.isPresentingPopup = false
            }
            .store(in: &cancellables)

        
        viewModel.carModelPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                if self.isPresentingPopup {
                    let selectedItem = self.viewModel.carModelList.first(where: { $0.id == self.model.carModelId })
                    self.presentBasicList(title: "model_year".localized, list: self.viewModel.carModelList, selectedItem: selectedItem) { selected in
                        if let selected = selected {
                            self.carModelPickerField.txtField.text = selected.name
                            self.model.carModelId = selected.id
                        } else {
                            self.carModelPickerField.txtField.text = ""
                            self.model.carModelId = nil
                        }
                    }
                } else {
                    if let selectedItem = self.viewModel.carModelList.first(where: { $0.id == self.model.carModelId }) {
                        self.carModelPickerField.txtField.text = selectedItem.name
                    }
                }
                self.isPresentingPopup = false
            }
            .store(in: &cancellables)
        
        viewModel.mainSectionPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                if self.isPresentingPopup {
                    let selectedItem = self.viewModel.mainSectionList.first(where: { $0.id == self.model.mainSectionId })
                    self.presentBasicList(title: "main_category".localized, list: self.viewModel.mainSectionList, selectedItem: selectedItem) { selected in
                        if let selected = selected {
                            self.mainCategoryPickerField.txtField.text = selected.name
                            self.viewModel.getSubSections(mainSectionId: selected.id ?? 0)
                            self.model.mainSectionId = selected.id
                        } else {
                            self.mainCategoryPickerField.txtField.text = ""
                            self.model.mainSectionId = nil
                            self.viewModel.subSectionList = []
                            self.tableView.reloadData()
                            self.selectedIndex = nil
                        }
                    }
                } else {
                    if let selectedItem = self.viewModel.mainSectionList.first(where: { $0.id == self.model.mainSectionId }) {
                        self.mainCategoryPickerField.txtField.text = selectedItem.name
                        self.viewModel.getSubSections(mainSectionId: selectedItem.id ?? 0)
                    }
                }
                self.isPresentingPopup = false
            }
            .store(in: &cancellables)
        
        viewModel.subSectionPublisher
            .dropFirst()
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                self.tableView.reloadData()

                if let subsectionId = self.model.subsectionId, let index = self.viewModel.subSectionList.firstIndex(where: { $0.id == subsectionId }) {
                    self.selectedIndex = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [self.selectedIndex!], with: .none)
                }
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    func presentBasicList(title: String, list: [PickerModel], selectedItem: PickerModel? = nil, completion: @escaping (PickerModel?) -> Void) {
        let vc = PickerListPopup()
        vc.titleText = title
        vc.pickerList = list
        vc.selectedItem = selectedItem
        vc.onItemSelected = { value in
            completion(value)
        }
        vc.appear(sender: self)
    }
    
    func validateCarType() -> Int?{
        guard let carTypeId = model.carTypeId else {
            show(errorMessage: ValidationError.carType.localizedDescription)
            return nil
        }
        return carTypeId
    }
    
    //MARK: - Actions -
    
    @objc private func onBackViewTapped() {
        self.hide()
    }
    
    @objc private func onRateBtnTapped(){
        ratingRadioBtn.isOn.toggle()
    }
    
    @IBAction func didTapShowRsult(_ sender: UIButton) {
        if let engineCapacity = engineCapacityField.txtField.text , !engineCapacity.trimWhiteSpace().isEmpty{
            model.engineCapacity = engineCapacity
        } else {
            model.engineCapacity = nil
        }
        
        model.rate = ratingRadioBtn.isOn ? "top" : nil
        if let selectedIndex = selectedIndex {
            model.subsectionId =  viewModel.subSectionList[selectedIndex.row].id
        } else {
            model.subsectionId = nil
        }
        delegate?.didSelectFilter(model: model)
        hide()
    }
}

extension FilterPopup : PickerFieldViewDelegate {
    
    func pickerFieldViewDidTap(_ view: PickerFieldView) {
        isPresentingPopup = true
        switch view.pickerType {
        case .importedCountry:
            viewModel.getImportingCountries()
        case .carBrand:
            viewModel.getCarCompanies()
        case .carType:
            viewModel.getCarType()
        case .carModel:
            guard let carTypeId  = validateCarType() else { return }
            viewModel.getCarModel(carTypeId: carTypeId)
        case .state:
            let selectedItem = viewModel.stateList.first(where: { $0.apiValue == model.status })
            self.presentBasicList(title: "condition".localized, list: viewModel.stateList,selectedItem: selectedItem) { selected in
                if let selected = selected {
                    self.statusPickerField.txtField.text = selected.name
                    self.model.status = selected.apiValue
                } else {
                    self.statusPickerField.txtField.text = ""
                    self.model.status = nil
                }
            }
        case .transmissionType:
            let selectedItem = viewModel.transmissionList.first(where: { $0.apiValue == model.transmission })
            self.presentBasicList(title: "transmission_type".localized, list: viewModel.transmissionList,selectedItem: selectedItem) { selected in
                if let selected = selected {
                    self.gearTypePickerField.txtField.text = selected.name
                    self.model.transmission = selected.apiValue
                } else {
                    self.gearTypePickerField.txtField.text = ""
                    self.model.transmission = nil
                }
            }
        case .fuelType:
            let selectedItem = viewModel.fuelTypeList.first(where: { $0.apiValue == model.fuelType })
            self.presentBasicList(title: "fuel_type".localized, list: viewModel.fuelTypeList,selectedItem: selectedItem) { selected in
                if let selected = selected {
                    self.fuelTypePickerField.txtField.text = selected.name
                    self.model.fuelType = selected.apiValue
                } else {
                    self.fuelTypePickerField.txtField.text = ""
                    self.model.fuelType = nil
                }
            }
        case .mainCategory:
            viewModel.getMainSections()
        default:
            break
        }
    }
}

//MARK: - TableView Configuration -

extension FilterPopup : UITableViewDelegate , UITableViewDataSource {
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: PopupSelectionViewCell.self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.subSectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: PopupSelectionViewCell.self, for: indexPath)
        cell.selectionLabel.text =  viewModel.subSectionList[indexPath.row].name
        cell.selectionStyle = .none
        cell.isCircleFilled = (indexPath == selectedIndex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath {
            selectedIndex = nil
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }
        if let previous = selectedIndex {
            selectedIndex = indexPath
            tableView.reloadRows(at: [previous, indexPath], with: .none)
            return
        }
        selectedIndex = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

//MARK: - Delegation -
protocol FilterPopupDelegate : AnyObject {
    func didSelectFilter(model: SubcategoriesModel)
}

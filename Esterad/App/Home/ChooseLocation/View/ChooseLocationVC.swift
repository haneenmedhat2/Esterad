//
//  ChooseLocationVC.swift
//  Esterad
//
//  Created by Haneen on 12/11/2025.
//

import UIKit
import GoogleMaps
import CoreLocation

class ChooseLocationVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet private weak var locationView: UIView!
    @IBOutlet weak var addressTextField: GeneralTextField!
    @IBOutlet private weak var mapContainerView: GMSMapView!
    
    //MARK: - Properties -
    
    let viewModel : ChooseLocationVMProtocol
    private var locationManager = CLLocationManager()
    private var userMarker: GMSMarker?
    private var latitude : Double = 0.0
    private var longitude : Double = 0.0
    
    //MARK: - Initializer -
    
    init(viewModel : ChooseLocationVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "ChooseLocationVC", bundle: nil)
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
        self.setGradientBackground()
        self.title = "set_location".localized
        bindViewModel()
        setupLocationView()
        setupLocationManager()
    }
    
    //MARK: - Configuration -
    
    private func setupLocationView() {
        locationView.layer.cornerRadius = 8
        locationView.clipsToBounds = true
        locationView.backgroundColor = .white
    }
    
    //MARK: - View Model Binding -
    
    private func bindViewModel() {
        loading(viewModel.isLoadingPublisher)
        
        viewModel.updateLocationPublisher
            .sinkOnMain{ [weak self] result in
                guard let self = self else { return }
                Session.user = result.data
                show(successMessage: result.message)
                pop()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapConfirmLocation(_ sender: UIButton) {
        viewModel.updateLocation(model: UpdateLocationModel(lat: latitude, long: longitude, address: addressTextField.txtField.text ?? ""))
    }
    
    @IBAction func didTapCurrentLocation(_ sender: UIButton) {
        checkLocationPermissionAndProceed()
    }
}

    //MARK: - Map Configuration -
    
    extension ChooseLocationVC: CLLocationManagerDelegate {
        
        private func setupLocationManager() {
            mapContainerView.delegate = self
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            if let savedLatString = UserDefaults.user?.lat,
               let savedLngString = UserDefaults.user?.long,
               let savedLat = Double(savedLatString),
               let savedLng = Double(savedLngString) {
                
                latitude = savedLat
                longitude = savedLng
                
                let savedCoordinate = CLLocationCoordinate2D(latitude: savedLat, longitude: savedLng)
                let camera = GMSCameraPosition(latitude: savedLat, longitude: savedLng, zoom: 16.0)
                mapContainerView.animate(to: camera)
                
                if userMarker == nil {
                    userMarker = GMSMarker()
                    userMarker?.map = mapContainerView
                }
                userMarker?.position = savedCoordinate
                
                reverseGeocode(coordinate: savedCoordinate)
                
            } else {
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestLocation()
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                mapContainerView.isMyLocationEnabled = true
                mapContainerView.settings.myLocationButton = false
            default:
                break
            }
        }
        
        func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }
            let camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
            
            if userMarker == nil {
                userMarker = GMSMarker()
                userMarker?.map = mapContainerView
            }
            userMarker?.position = location.coordinate
            reverseGeocode(coordinate: location.coordinate)
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            mapContainerView.animate(to: camera)
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
            print("Map Error : \(error.localizedDescription)")
        }
        
        private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
            AppHelper.getAddressFromCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude){ [weak self] address in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.addressTextField.txtField.text = address
                }
            }
        }
        
        private func checkLocationPermissionAndProceed() {
            let status = locationManager.authorizationStatus
            
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                getCurrentLocation()
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .denied, .restricted:
                showLocationPermissionAlert()
                
            @unknown default:
                break
            }
        }

        private func getCurrentLocation() {
            guard let location = locationManager.location else {
                locationManager.requestLocation()
                return
            }
            
            let coordinate = location.coordinate
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            
            if userMarker == nil {
                userMarker = GMSMarker()
                userMarker?.map = mapContainerView
            }
            
            userMarker?.position = coordinate
            let camera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16.0)
            mapContainerView.animate(to: camera)
            reverseGeocode(coordinate: coordinate)
        }
        
        private func showLocationPermissionAlert() {
            let alert = UIAlertController(
                title: "location_permission_title".localized,
                message: "location_permission_message".localized,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "open_settings".localized, style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - GMSMapViewDelegate -
    
    extension ChooseLocationVC : GMSMapViewDelegate {
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            
            if userMarker == nil {
                userMarker = GMSMarker()
                userMarker?.map = mapView
            }
            userMarker?.position = coordinate
            mapView.animate(toLocation: coordinate)
            reverseGeocode(coordinate: coordinate)
        }
    }

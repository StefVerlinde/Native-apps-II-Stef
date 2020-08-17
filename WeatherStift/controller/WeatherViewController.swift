//
//  ViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

protocol WeatherViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var condLabel: UILabel!
    
    private let defaultCity = "Gent "
    
    private let weatherManager = WeatherManager()
    private let cacheManager = CacheManager()
    //lazy for lazy loading. When the app is initialized, this attribute is not until it is called
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let city = cacheManager.getCachedCity() ?? defaultCity
        
        fetchWeather(byCity: city)
    }
    
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byCity city: String){
        showAnimation()
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        hideAnimation()
        conditionImageView.image = UIImage(named: "imSad")
        navigationItem.title = ""
        tempLabel.text = "Oops!"
        condLabel.text = "Something went wrong. Please try again!"
        Loaf(error.localizedDescription , state: .error, location: .bottom, sender: self).show()
    }
    
    private func updateView(with model: WeatherModel){
        hideAnimation()
        
        tempLabel.text = model.temp.toString().appending("°C")
        condLabel.text = model.conditionDescription
        navigationItem.title = model.countryName
        conditionImageView.image = UIImage(named: model.conditionImage)
    }
    
    private func hideAnimation(){
        conditionImageView.hideSkeleton()
        tempLabel.hideSkeleton()
        condLabel.hideSkeleton()
    }
    
    private func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton()
        tempLabel.showAnimatedGradientSkeleton()
        condLabel.showAnimatedGradientSkeleton()
    }


    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promtForLocationPermission()
        }
    }
    
    private func promtForLocationPermission() {
        let alertController = UIAlertController(title: "Requires Location Permission", message: "Would you like to enable location permission in settings?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension WeatherViewController: WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let this = self else {return}
            print("\(model.countryName)")
            this.updateView(with: model)
        })
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            fetchWeather(byLocation: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
}

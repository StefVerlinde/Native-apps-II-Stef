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
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    private let defaultCity = "Gent"
    
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
        
        if(cacheManager.getCachedSystem() ?? true) {
            fetchWeatherMetric(byCity: city)
        } else {
            fetchWeatherImperial(byCity: city)
        }
        
    }
    
    private func fetchWeatherMetric(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeatherMetric(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func fetchWeatherMetric(byCity city: String){
        showAnimation()
        weatherManager.fetchWeatherMetric(byCity: city) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func fetchWeatherImperial(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeatherImperial(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func fetchWeatherImperial(byCity city: String){
        showAnimation()
        weatherManager.fetchWeatherImperial(byCity: city) { [weak self] (result) in
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
    
    func updateView(with model: WeatherModel){
        hideAnimation()
        
        if(cacheManager.getCachedSystem() ?? true){
            tempLabel.text = model.temp.toString().appending("°C")
        } else {
            tempLabel.text = model.temp.toString().appending("°F")
        }
        condLabel.text = model.conditionDescription
        windLabel.text = model.wind.toString().appending("M/S")
        cloudsLabel.text = model.clouds.toString().appending("%")
        sunriseLabel.text = model.sunrise
        sunsetLabel.text = model.sunset
        navigationItem.title = model.countryName
        conditionImageView.image = UIImage(named: model.conditionImage)
    }

    private func hideAnimation(){
        conditionImageView.hideSkeleton()
        tempLabel.hideSkeleton()
        condLabel.hideSkeleton()
        windLabel.hideSkeleton()
        cloudsLabel.hideSkeleton()
        sunriseLabel.hideSkeleton()
        sunsetLabel.hideSkeleton()
    }
    
    private func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton()
        tempLabel.showAnimatedGradientSkeleton()
        condLabel.showAnimatedGradientSkeleton()
        windLabel.showAnimatedSkeleton()
        cloudsLabel.showAnimatedSkeleton()
        sunriseLabel.showAnimatedSkeleton()
        sunsetLabel.showAnimatedSkeleton()
    }


    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
        if segue.identifier == "showSettings" {
            if let destination = segue.destination as? SettingsViewController {
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
            if(cacheManager.getCachedSystem() ?? true) {
                fetchWeatherMetric(byLocation: location)
            } else {
                fetchWeatherImperial(byLocation: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
}

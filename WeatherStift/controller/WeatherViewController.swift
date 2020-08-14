//
//  ViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit
import SkeletonView

protocol WeatherViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var condLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimation()
        fetchWeather()
        //weatherManager.fetchWeather(byCity: "Gent")
    }
    
    private func fetchWeather(){
        weatherManager.fetchWeather(byCity: "Gent") { [weak self] (result) in
            guard let this = self else {return}
            switch result {
            case .success(let model):
                this.updateView(with: model)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
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

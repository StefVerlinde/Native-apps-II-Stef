//
//  ViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit
import SkeletonView

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
        weatherManager.fetchWeather(byCity: "Destelbergen") { [weak self] (result) in
            guard let this = self else {return}
            switch result {
            case .success(let weatherData):
                this.updateView(with: weatherData)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateView(with data: WeatherData){
        hideAnimation()
        
        tempLabel.text = data.main.temp.toString().appending("°C")
        condLabel.text = data.weather.first?.description
        navigationItem.title = data.name
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


    @IBAction func addLocationButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
    }
}


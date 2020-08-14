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
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
    }
}


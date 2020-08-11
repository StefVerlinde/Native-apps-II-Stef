//
//  ViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var condLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.fetchWeather(city: "Gent")
    }


    @IBAction func addLocationButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
    }
}


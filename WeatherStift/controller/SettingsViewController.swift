//
//  SettingsViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 30/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let cacheManager = CacheManager()
    private let weatherManager = WeatherManager()
    weak var delegate: WeatherViewControllerDelegate?
    
    
    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Imperial/Metric system"
        let metricSwitch = UISwitch()
        metricSwitch.isOn = cacheManager.getCachedSystem() ?? true
        metricSwitch.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
        cell.accessoryView = metricSwitch
        return cell
    }
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        let query:String = cacheManager.getCachedCity() ?? "Gent"
        if sender.isOn {
            self.cacheManager.cacheSystem(value: true)
            weatherManager.fetchWeatherMetric(byCity: query) { [weak self] (result) in
                guard let this = self else {return}
                switch result {
                case .success(let model):
                    this.handleSearchSuccess(model: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        else {
            self.cacheManager.cacheSystem(value: false)
            weatherManager.fetchWeatherImperial(byCity: query) { [weak self] (result) in
                guard let this = self else {return}
                switch result {
                case .success(let model):
                    this.handleSearchSuccess(model: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let this = self else {return}
            this.delegate?.didUpdateWeatherFromSearch(model: model)
        }
    }
}

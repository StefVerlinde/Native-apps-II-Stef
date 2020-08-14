//
//  AddCityViewController.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 12/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import UIKit

class AddCityViewController: UIViewController {
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityTextField.becomeFirstResponder()
    }
    
    private func setupViews(){
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        statusLabel.isHidden = true
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissCityViewController))
        //This + extension methode removes error when user touches on addCityView
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissCityViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        statusLabel.isHidden = true
        //guard to make sure it's not empty
        guard let query = cityTextField.text, !query.isEmpty else {
            showSearchError(text: "City cannot be empty. Please try again!")
            return}
        handleSearch(query: query)
    }
    
    private func showSearchError(text: String){
        statusLabel.isHidden = false
        statusLabel.textColor = .systemRed
        statusLabel.text = text
    }
    
    private func handleSearch(query: String){
        activityIndicator.startAnimating()
        weatherManager.fetchWeather(byCity: query) { [weak self] (result) in
            guard let this = self else {return}
            this.activityIndicator.stopAnimating()
            switch result {
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                this.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemGreen
        statusLabel.text = "Success!"
    }
}

extension AddCityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

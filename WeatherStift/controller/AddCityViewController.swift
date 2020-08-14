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
        
    }
}

extension AddCityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

//
//  WeatherManager.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import Foundation
import Alamofire

struct WeatherManager {
    private let API_KEY = "c4f697e578e4a5fc72b84ce28b92d66e"
    
    func fetchWeather(city: String) {
        //When searching for text, u have to encode it. For example: city with a space have to be handled
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        
        AF.request(urlString).responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                print("weatherData: \(weatherData)")
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

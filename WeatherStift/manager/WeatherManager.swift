//
//  WeatherManager.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import Foundation
import Alamofire

//Custom weather error
enum WeatherError: Error, LocalizedError {
    case unknown
    case invalidCity
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .invalidCity:
            return "Invalid city. Please try again!"
        }
    }
}

struct WeatherManager {
    private let API_KEY = "c4f697e578e4a5fc72b84ce28b92d66e"
    
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        //When searching for text, u have to encode it. For example: city with a space have to be handled
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        
        AF.request(urlString).responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                completion(.success(model))
            case .failure(let error):
                if response.response?.statusCode == 404 {
                    let invalidCityError = WeatherError.invalidCity
                    completion(.failure(invalidCityError))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}

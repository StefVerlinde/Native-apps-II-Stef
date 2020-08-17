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
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .invalidCity:
            return "Invalid city. Please try again!"
        case .custom(let description):
            return description
        }
    }
}

struct WeatherManager {
    private let API_KEY = "c4f697e578e4a5fc72b84ce28b92d66e"
    private let cacheManager = CacheManager()
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        //When searching for text, u have to encode it. For example: city with a space have to be handled
        let path = "https://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&lon=%f"
        let urlString = String(format: path, API_KEY, lat, lon)
        
        handleRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        //When searching for text, u have to encode it. For example: city with a space have to be handled
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        
        handleRequest(urlString: urlString, completion: completion)
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        //Validate is so we can use error.responseCode and not response.response?.statusCode
        AF.request(urlString).validate().responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                self.cacheManager.cacheCity(cityName: model.countryName)
                completion(.success(model))
            case .failure(let error):
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        if error.responseCode == 404,
            let data = data,
            let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.custom(description: message)
        } else {
            return nil
        }
    }
}

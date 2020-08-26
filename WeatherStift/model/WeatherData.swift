//
//  WeatherData.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 11/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import Foundation

//Decodable can convert a set of data from a JSON Object to an equivalent StructorClass
struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    
    var model: WeatherModel {
        return WeatherModel(countryName: name, temp: main.temp.toInt(), conditionId: weather.first?.id ?? 0, conditionDescription: weather.first?.description ?? "", wind: wind.speed, clouds: clouds.all, sunrise: unixToDate(timeresult: sys.sunrise), sunset: unixToDate(timeresult: sys.sunset))
    }
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
}

struct Wind: Decodable {
    let speed: Double //wind speed in meter/seconde
}

struct Clouds: Decodable {
    let all: Double //clouds in percentage
}

struct Sys: Decodable {
    let sunrise: Double
    let sunset: Double
}

struct WeatherModel {
    let countryName: String
    let temp: Int
    let conditionId: Int
    let conditionDescription: String
    let wind: Double
    let clouds: Double
    let sunrise: String
    let sunset: String
    
    var conditionImage: String {
        switch conditionId {
        case 200...299:
            return "imThunderstorm"
        case 300...399:
            return "imDrizzle"
        case 500...599:
            return "imRain"
        case 600...699:
            return "imSnow"
        case 700...799:
            return "imAtmosphere"
        case 800:
            return "imClear"
        default:
            return "imClouds"
        }
    }
}

private func unixToDate(timeresult: Double) -> String {
    let date = Date(timeIntervalSince1970: timeresult)
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
    dateFormatter.timeZone = .current
    dateFormatter.dateFormat = "HH:mm"
    let localDate = dateFormatter.string(from: date)
    return localDate
}

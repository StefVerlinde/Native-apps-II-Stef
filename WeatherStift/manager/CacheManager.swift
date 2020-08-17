//
//  StoreManager.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 17/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import Foundation

struct CacheManager {
    
    private let vault = UserDefaults.standard
    
    enum Key: String {
        case city
    }
    
    func cacheCity(cityName: String) {
        vault.set(cityName, forKey: Key.city.rawValue)
    }
    
    func getCachedCity() -> String? {
        return vault.value(forKey: Key.city.rawValue) as? String
    }
    
}

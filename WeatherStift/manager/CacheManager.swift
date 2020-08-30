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
        case system
    }
    
    func cacheCity(cityName: String) {
        vault.set(cityName, forKey: Key.city.rawValue)
    }
    
    func getCachedCity() -> String? {
        return vault.value(forKey: Key.city.rawValue) as? String
    }
    
    func cacheSystem(value: Bool) {
        vault.set(value, forKey: Key.system.rawValue)
    }
    
    func getCachedSystem() -> Bool? {
        return vault.value(forKey: Key.system.rawValue) as? Bool
    }
}

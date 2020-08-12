//
//  Double+Extension.swift
//  WeatherStift
//
//  Created by Stef Verlinde on 12/08/2020.
//  Copyright © 2020 Stef Verlinde. All rights reserved.
//

import Foundation

extension Double {
    func toString() -> String {
        return String(format: "%.1f", self)
    }
}

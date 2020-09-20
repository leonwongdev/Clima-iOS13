//
//  File.swift
//  Clima
//
//  Created by Leon Wong on 10/9/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Codable { //Decodable, Encodable can be replace with typealias: Codable
    let name: String
    let main: Main // another struct is needed
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double// property name has to match the data name in JSON
}

struct Weather: Codable {
    let id: Int
    let description: String
}

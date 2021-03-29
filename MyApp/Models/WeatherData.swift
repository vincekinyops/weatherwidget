//
//  WeatherData.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/26/21.
//

import Foundation

enum WeatherType: String, Codable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case cloudysunny = "cloudysunny"
    case rainy = "rainy"
    case snowy = "snowy"
    case drizzle = "drizzle"
    case thunder = "thunder"
    case clear = "clear"
    case atmospheric = "atmospheric"
    case sunrainy = "sunrainy"
    case windy = "windy"
    case freezingrain = "freezingrain"
    
    init(id: Int) {
        switch id {
        case 200...299:
            self = .thunder
        case 300...399:
            self = .drizzle
        case 500...504:
            self = .rainy
        case 511...540:
            self = .freezingrain
        case 600...699:
            self = .snowy
        case 700...799:
            self = .windy //.atmospheric
        case 800:
            self = .sunny
        case 801...802:
            self = .cloudysunny
        case 802:
            self = .cloudy
        case 803...804:
            self = .cloudy
        default:
            self = .sunny
        }
    }
}

struct Details: Codable {
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Double
    var humidity: Double
    
    enum CodingKeys: String, CodingKey, Codable {
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case temp = "temp"
        case pressure = "pressure"
        case humidity = "humidity"
    }
}

struct WeatherInfo: Codable {
    var main: String
    var description: String
    var id: Int
    var icon: String
}

struct WeatherResult: Codable, Identifiable {
    enum CodingKeys: String, CodingKey, Codable {
        case details = "main"
        case weather = "weather"
        case id = "id"
    }
    
    var details: Details
    var weather: [WeatherInfo]
    var id: Int
}

extension WeatherResult {
    
    static let `default` = WeatherResult(
        details: Details(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0),
        weather: [
            WeatherInfo(main: "Clear", description: "Clear", id: 802, icon: "01d")
        ], id: 0)
}

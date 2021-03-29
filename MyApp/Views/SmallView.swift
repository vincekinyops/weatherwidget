//
//  SmallView.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/26/21.
//

import Foundation
import UIKit

class SmallView: UIView, WidgetViewBuilder {
    var weatherData: WeatherResult = WeatherResult.default {
        didSet {
            weatherImage.image = UIImage(named: WeatherType(id: weatherData.weather.first!.id).rawValue)
            weatherLabel.text = weatherData.weather.first!.description
        }
    }
    var backgroundImage: UIImage = UIImage() {
        didSet {
            backgroundView.image = backgroundImage
        }
    }
    
    var locationData: LocationData = LocationData.default {
        didSet {
            locationLabel.text = locationData.locationString
        }
    }
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
}

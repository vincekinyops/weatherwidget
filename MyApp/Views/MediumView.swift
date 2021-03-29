//
//  MediumView.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/27/21.
//

import Foundation
import UIKit

class MediumView: UIView, WidgetViewBuilder {
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
    
    var locationString: String = "" {
        didSet {
            locationLabel.text = locationString
        }
    }
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
}

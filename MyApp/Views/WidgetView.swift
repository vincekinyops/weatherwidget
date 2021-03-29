//
//  WidgetView.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/26/21.
//

import Foundation
import UIKit

protocol WidgetViewBuilder: UIView {
    var weatherData: WeatherResult { get set }
    var backgroundImage: UIImage { get set }
    var locationData: LocationData { get set }
}


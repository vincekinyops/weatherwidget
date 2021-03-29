//
//  FileSharing+Extensions.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/27/21.
//

import Foundation
import UIKit

let groupName = "group.com.markquinopa.widgets"
let sharedImageName = "sharedImage.png"
let sharedLocation = "sharedLocation"

extension UserDefaults {
    static let group = UserDefaults(suiteName: groupName)
}

extension UserDefaults {
    struct Keys {
        static let photo = "photoSelected"
        static let photoID = "UNIQUE_ID_MARKQUINOPA"
        static let locationID = "locationID"
    }
}

extension FileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!
    }
    
    static func saveImage(uiImage: UIImage) {
        if let data = uiImage.pngData() {
            let filename = sharedContainerURL().appendingPathComponent(sharedImageName)
            try? data.write(to: filename)
        }
    }
    
    static func getSavedImage() -> UIImage? {
        return UIImage(contentsOfFile: FileManager.sharedContainerURL().appendingPathComponent(sharedImageName).path)
    }
}



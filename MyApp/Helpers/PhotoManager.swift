//
//  PhotoManager.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/27/21.
//

import Foundation
import SwiftUI
import WidgetKit
import NotificationCenter

// UUID().uuidString

extension NSNotification.Name {
    static let changeImageNotif = "changeImageNotif"
}

@available(iOS 14.0, *)
final class PhotoManager: NSObject, ObservableObject {
    
    @Published var photos = [String]()
    
    // MARK: - SETUP
    override init() {
        super.init()
        
        photos = PhotoHelper.getImageIdsFromUserDefault()
    }
    
    func appendImage(image: UIImage) {
        
        // Save image in userdefaults
        if let userDefaults = UserDefaults.group {
            
            if let jpegRepresentation = image.jpegData(compressionQuality: 0.5) {
                
                // set global unique id to lessen adding of new images
                //let id = UUID().uuidString
                userDefaults.removeObject(forKey: UserDefaults.Keys.photoID)
                userDefaults.set(jpegRepresentation, forKey: UserDefaults.Keys.photoID)
                userDefaults.synchronize()
                
                // Append the list and save
                photos.removeAll() // ensure only 1 photo is added each time
                photos.append(UserDefaults.Keys.photoID)
                saveIntoUserDefaults()
                
                // Notify the widget to reload all items
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func saveIntoUserDefaults() {
        if let userDefaults = UserDefaults(suiteName: groupName) {
            
            let data = try! JSONEncoder().encode(photos)
            userDefaults.set(data, forKey: UserDefaults.Keys.photo)
        }
    }
    
}

struct PhotoHelper {
    static func getImageIdsFromUserDefault() -> [String] {
        
        if let userDefaults = UserDefaults(suiteName: groupName) {
            if let data = userDefaults.data(forKey: UserDefaults.Keys.photo) {
                return try! JSONDecoder().decode([String].self, from: data)
            }
        }
        
        return [String]()
    }
    
    static func getImageFromUserDefaults(key: String) -> UIImage {
        if let userDefaults = UserDefaults(suiteName: groupName) {
            if let imageData = userDefaults.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return UIImage(systemName: "photo.fill.on.rectangle.fill")!
    }
}

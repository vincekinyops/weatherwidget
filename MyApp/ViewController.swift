//
//  ViewController.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/26/21.
//

import UIKit
import PhotosUI
import SwiftUI
import Combine

@available(iOS 14.0, *)
class ViewController: UIViewController {
    private var photoManager = PhotoManager()
    private var locationManager: LocationManager!
    private var cancellable: AnyCancellable?
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var changeBGButton: UIButton!
    var selectedImage: UIImage? {
        didSet {
            setBackgroundImage()
        }
    }
    var widgets = [WidgetViewBuilder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad ")
        locationManager = LocationManager()
        
        widgets = setupWidgetOptions()
        setupSlideScrollView(widgets: widgets)
        pageControl.currentPage = 0
        pageControl.numberOfPages = widgets.count
        
        let defaultImageID = PhotoHelper.getImageIdsFromUserDefault()
        if let firstID = defaultImageID.first {
            let image = PhotoHelper.getImageFromUserDefaults(key: firstID)
            selectedImage = image
        }
        
        cancellable = locationManager.$locationData.sink { [weak self] data in
            self?.setWeather(data)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let alert = UIAlertController(title: "Test", message: "Testing close", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func handleChangeBackground(_ sender: UIButton) {
        // Enabling both pickers for different ios versions, haven't tested
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func setBackgroundImage() {
        for widgetView in widgets {
            widgetView.backgroundImage = selectedImage!
        }
    }
    
    func setWeather(_ locationData: LocationData) {
        let locString = locationData.locationString ?? "Makati City, Philippines"
        apiService.fetchAPIResource(WeatherWidgetResource(locString, apiKey: Config.API_KEY))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("Request completed")
                }
            }, receiveValue: { [weak self] data in
                for widgetView in self!.widgets {
                    widgetView.weatherData = data
                    widgetView.locationString = locString
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
@available(iOS 14.0, *)
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            photoManager.appendImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        for image in results {
            if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                image.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    
                    guard let imageResult = image else {
                        print(error?.localizedDescription as Any)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.selectedImage = imageResult as? UIImage
                        self.photoManager.appendImage(image: imageResult as! UIImage)
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Setup
@available(iOS 14.0, *)
extension ViewController {
    func setupSlideScrollView(widgets : [WidgetViewBuilder]) {
        let width = view.frame.width * CGFloat(widgets.count)
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: width, height: 0)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< widgets.count {
            widgets[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(widgets[i])
        }
    }
    
    func setupWidgetOptions() -> [WidgetViewBuilder] {
        let smallView = Bundle.main.loadNibNamed("SmallView", owner: self, options: nil)?.first as! WidgetViewBuilder
        let mediumView = Bundle.main.loadNibNamed("MediumView", owner: self, options: nil)?.first as! WidgetViewBuilder
        let largeView = Bundle.main.loadNibNamed("LargeView", owner: self, options: nil)?.first as! WidgetViewBuilder
        
        return [smallView, mediumView, largeView]
    }
}

// MARK: - UIScrollViewDelegate
@available(iOS 14.0, *)
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // set page control current selected dot
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        // to disable scrolling vertically
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

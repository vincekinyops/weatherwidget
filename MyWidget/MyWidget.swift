//
//  MyWidget.swift
//  MyWidget
//
//  Created by Lanex-Mark on 3/27/21.
//

import WidgetKit
import SwiftUI
import Combine

private var cancellables = Set<AnyCancellable>()

@available(iOSApplicationExtension 14.0, *)
struct Provider: TimelineProvider {
    private let locationManager = LocationManager()
    private let apiService = APIService()
    
    let locationInfo: String? = nil
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageID: nil, weatherData: WeatherResult.default, locationData: LocationData.default)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imageID: nil, weatherData: WeatherResult.default, locationData: LocationData.default)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // get location string from location manager initiated
        let location = locationManager.locationData
        
        // get image id from user defaults
        let imageIDS = PhotoHelper.getImageIdsFromUserDefault()
        
        // update every 1minute
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        
        apiService.fetchAPIResource(WeatherWidgetResource(location, apiKey: Config.API_KEY))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    print(error.localizedDescription)
                    let entries = [
                        SimpleEntry(date: currentDate, imageID: imageIDS.first, weatherData: WeatherResult.default, locationData: location),
                        SimpleEntry(date: nextDate, imageID: imageIDS.first, weatherData: WeatherResult.default, locationData: location)
                    ]
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                case .finished:
                    print("Request completed")
                }
            }, receiveValue: {
                let entries = [
                    SimpleEntry(date: currentDate, imageID: imageIDS.first, weatherData: $0, locationData: location),
                    SimpleEntry(date: nextDate, imageID: imageIDS.first, weatherData: $0, locationData: location)
                ]
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var imageID: String?
    //var locationString: String?
    var weatherData: WeatherResult
    var locationData: LocationData
}

@available(iOSApplicationExtension 14.0, *)
struct MyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    private static let appURL: URL = URL(string: "widget-deeplink://")!
    
    var locationString: String {
        return ""
    }
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    if let imageID = entry.imageID {
                        Image(uiImage: PhotoHelper.getImageFromUserDefaults(key: imageID))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(WeatherType(id: entry.weatherData.weather.first!.id).rawValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            Text(entry.weatherData.weather.first?.description ?? "Clear")
                                .kerning(-0.41)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .foregroundColor(Color.black)
                                .cornerRadius(5)
                        }
                        Text(entry.locationData.locationString)
                            .kerning(-0.41)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding(5)
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(Color.black)
                            .cornerRadius(5)
                            
                    }
                    .padding(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: geo.size.width * 0.95)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .widgetURL(MyWidgetEntryView.appURL)
        case .systemMedium:
            ZStack {
                if let imageID = entry.imageID {
                    Image(uiImage: PhotoHelper.getImageFromUserDefaults(key: imageID))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }
                VStack(alignment: .leading) {
                    HStack {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(WeatherType(id: entry.weatherData.weather.first!.id).rawValue)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .aspectRatio(contentMode: .fit)
                                Text(entry.weatherData.weather.first?.description ?? "Clear")
                                    .kerning(-0.41)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(5)
                                    .background(Color.white.opacity(0.8))
                                    .foregroundColor(Color.black)
                                    .cornerRadius(5)
                            }
                            Text(entry.locationData.locationString)
                                .kerning(-0.41)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .foregroundColor(Color.black)
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                    .padding(5)
                }
            }
            .widgetURL(MyWidgetEntryView.appURL)
        case .systemLarge:
            ZStack {
                if let imageID = entry.imageID {
                    Image(uiImage: PhotoHelper.getImageFromUserDefaults(key: imageID))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }
                VStack {
                    HStack {
                        Image(WeatherType(id: entry.weatherData.weather.first!.id).rawValue)
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text(entry.weatherData.weather.first?.description ?? "Clear")
                            .kerning(-0.41)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(5)
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(Color.black)
                            .cornerRadius(5)
                    }
                    
                    Text(entry.locationData.locationString)
                        .kerning(-0.41)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(Color.black)
                        .cornerRadius(5)
                }
                .padding(5)
            }
            .widgetURL(MyWidgetEntryView.appURL)
        @unknown default:
            Text("My Widget")
                .widgetURL(MyWidgetEntryView.appURL)
        }
    }
}

@main
struct MyWidget: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(), imageID: nil, weatherData: WeatherResult.default, locationData: LocationData.default))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

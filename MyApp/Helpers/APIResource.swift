//
//  APIResource.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/29/21.
//

import Combine
import Foundation

protocol NetworkService {
    var session: URLSession { get }
}

extension NetworkService {
    func fetch(url: URL) -> AnyPublisher<Data, APIError> {
        session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                if error.code.rawValue == -1009 {
                    return .offline
                }
                return .network(code: error.code.rawValue, description: error.localizedDescription)
            }
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

protocol APIResource {
    associatedtype Response: Decodable
    var serverPath: String { get }
    var methodPath: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIResource {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = serverPath
        components.path = methodPath
        components.queryItems = queryItems
        return components.url
    }
}

enum APIError: Error {
    case offline
    case network(code: Int, description: String)
    case invalidRequest(description: String)
    case unknown
}

class APIService: NetworkService {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension APIService {
    struct ErrorResponse: Decodable {
        let error: String
    }
}

extension APIService {
    func fetchAPIResource<Resource>(_ resource: Resource) -> AnyPublisher<WeatherResult, APIError> where Resource: APIResource {
        guard let url = resource.url else {
            let error = APIError.invalidRequest(description: "Invalid `resource.url`: \(String(describing: resource.url))")
            return Fail(error: error).eraseToAnyPublisher()
        }
        print("API Request URL: \(url)")
        return fetch(url: url)
            .flatMap(decode)
            .eraseToAnyPublisher()
    }

    func decode<Response>(data: Data) -> AnyPublisher<Response, APIError> where Response: Decodable {
        if let response = try? JSONDecoder().decode(Response.self, from: data) {
            return Just(response).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            return Fail(error: .invalidRequest(description: errorResponse.error)).eraseToAnyPublisher()
        } catch {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }
    }
}

// openweather api parameters
struct WeatherWidgetResource: APIResource {
    let serverPath = "api.openweathermap.org"
    let methodPath: String
    var queryItems: [URLQueryItem]?

    init(_ locationData: LocationData, apiKey: String) {
        methodPath = "/data/2.5/weather"
        queryItems = [
            URLQueryItem(name: "q", value: locationData.locationString),
            URLQueryItem(name: "APPID", value: apiKey)
        ]
    }
}

extension WeatherWidgetResource {
    struct Response: Decodable {
        let base: String
        let date: String
        let rates: [String: Double]
    }
}

struct Config {
    static let API_KEY = "c52b70c6f24c0c4deaea62bb23d228c1"
}

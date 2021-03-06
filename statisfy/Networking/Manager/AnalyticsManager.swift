//
//  TrackManager.swift
//  statisfy
//
//  Created by Avesta Barzegar on 2021-04-03.
//

import Foundation

enum NetworkResponse: String {
    case success
    case authError = "You need to be authenticated first. Try logging out and logging back in. Head to the settings page to relog."
    case badRequest = "Bad Request. Try relogging or resetting your connection."
    case outdated = "The url you requested is outdated. Try relogging or resetting your connection. Head to the settings page to relog."
    case failed = "Network request failed. Check your connection."
    case noData = "Response returned with no data to decode. Server returned no data, try relogging or resetting your connection. Head to the settings page to relog."
    case unableToDecode = "Could not decode the response. Try relogging or resetting your connection. Head to the settings page to relog."
}

enum Result<String> {
    case success
    case failure(String)
}

struct AnalyticsManager {
    
    private let router = Router<DataAnalyticsAPI>()
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        
        switch response.statusCode {
        case 200...299:
            return .success
        case 401...500:
            return .failure(NetworkResponse.authError.rawValue)
        case 501...599:
            return .failure(NetworkResponse.badRequest.rawValue)
        case 600:
            return .failure(NetworkResponse.outdated.rawValue)
        default:
            return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    func getTracks(timeRange: TimeRange, completion: @escaping (_ tracks: [TileInfo]?, _ error: String?) -> Void) {
        router.request(.track(timeRange: timeRange)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let tracks = try decoder.decode(TrackItem.self, from: responseData)
                        let tracksViewModel = TileInfo.generateArrayOfTileInfo(from: tracks)
                        completion(tracksViewModel, nil)
                        
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getArtists(timeRange: TimeRange, completion: @escaping (_ tracks: [TileInfo]?, _ error: String?) -> Void) {
        router.request(.artist(timeRange: timeRange)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let artists = try decoder.decode(ArtistItem.self, from: responseData)
                        let tracksViewModel = TileInfo.generateArrayOfTileInfo(from: artists)
                        completion(tracksViewModel, nil)
                        
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getRecent(completion: @escaping(_ items: [RecentTrackViewModel]?, _ error: String?) -> Void) {
        router.request(.recent) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let items = try decoder.decode(RecentItemsArr.self, from: responseData)
                        let tracksViewModel = RecentTrackViewModel.generateRecentTrackArray(from: items)
                        completion(tracksViewModel, nil)
                        
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
}

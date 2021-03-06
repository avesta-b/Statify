//
//  AuthManager.swift
//  statisfy
//
//  Created by Avesta Barzegar on 2021-03-28.
//

import Foundation

enum AuthConstants: String {
    
    case topScope = "user-top-read"
    case recentScope = "user-read-recently-played"
    case userInfoScope = "user-read-private"
    case userEmailScope = "user-read-email"
}

final class AuthManager {
    
    var scheme: String = "https"
    
    var baseURL: String = "accounts.spotify.com"
    
    var path: String = "/authorize"
        
    var redirectURI: String = "&redirect_uri=\(ClientInfo.redirectURI.rawValue)"
    
    var showDialog: String = "&show_dialog=TRUE"
    
    var parameters: [URLQueryItem]? = [
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "client_id", value: ClientInfo.clientId.rawValue),
        URLQueryItem(name: "scope", value: ("\(AuthConstants.topScope.rawValue),\(AuthConstants.recentScope.rawValue),\(AuthConstants.userInfoScope.rawValue),\(AuthConstants.userEmailScope.rawValue)")),
        URLQueryItem(name: "redirect_uri", value: ClientInfo.redirectURI.rawValue),
        URLQueryItem(name: "show_dialog", value: "TRUE")
    ]
    
    func urlBuilder() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = baseURL
        components.path = path
        components.queryItems = parameters
        let url = components.url
        return url
    }
    
    static let shared = AuthManager()
    
    private init() {}
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
    
    var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
}

//
//  Router.swift
//  statisfy
//
//  Created by Avesta Barzegar on 2021-04-03.
//

import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {
    
    private var task: URLSessionTask?
    private let session: URLSession = URLSession(configuration: .default)
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(bodyParameters: let bodyParameters,
                                    urlParameters: let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
            case .requestParametersAndHeaders(bodyParameters: let bodyParameters,
                                              urlParameters: let urlParameters,
                                              additionalHeaders: let additionalHeaders):
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
            case .requestBodyURLEncoded(bodyParameters: let bodyParameters,
                                        urlParameters: let urlParameters):
                try self.configureParametersURLEncoded(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParametersURLEncoded(bodyParameters: Parameters?,
                                                   urlParameters: Parameters?,
                                                   request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try URLBodyEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            if let bodyParameteres = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameteres)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

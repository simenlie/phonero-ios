//
//  NetworkService.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation


enum Result<Value> {
    case success(Value)
    case failure(Error)
}

struct MessageModel: Codable {
    let status: String?
    let message: String?
    let error: Int?
}

/// A protocol for making network requests
protocol Requestable {
    func executeDataRequest(route: Router, completion: ((Result<Data>) -> Void)?) -> URLSessionDataTask?
}

enum NetworkError: Error {
    case cannotParse
    case noInternet
    case serverError(MessageModel?)
    case connectionFailure(String)
    case unauthorized
    case forbidden
    case cannotBuildURL
}

/// A service performing network requests
struct NetworkService: Requestable {

    // MARK: - Requestable

    /// Executes a route request and returns a Result<Data> object async
    func executeDataRequest(route: Router, completion: ((Result<Data>) -> Void)?) -> URLSessionDataTask? {
        return execute(request: route.request) { (data, response, error) in
            do {
                let validData = try self.handle(responseData: data,
                                                response: response,
                                                responseError: error)
                completion?(.success(validData))
            } catch {
                completion?(.failure(error))
            }
        }
    }

    // MARK: - Private helper funcs

    private func execute(request: Request, completion: @escaping (_ responseData: Data?, _ response: URLResponse?, _ responseError: Error?) -> Void) -> URLSessionDataTask {
        let urlRequest = RequestBuilder.buildUrlRequest(request: request)

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: urlRequest) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                completion(responseData, response, responseError)
            }
        }

        task.resume()
        return task
    }

    // MARK: Error handling

    private func handle(responseData: Data?,
                        response: URLResponse?,
                        responseError: Error?) throws -> Data {
        logCall(jsonData: responseData, responseError: responseError, response: response)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if httpResponse.statusCode == 403 {
                throw NetworkError.forbidden
            }
            if case 400..<600 = httpResponse.statusCode {
                let errorModel = parseJSONError(responseData: responseData)
                throw NetworkError.serverError(errorModel)
            }
        }
        if let error = responseError {
            if let urlError = error as? URLError {
                if urlError.code == .notConnectedToInternet {
                    throw NetworkError.noInternet
                }
            }
            throw NetworkError.connectionFailure(error.localizedDescription)
        }
        guard let validData = responseData
            else { throw NetworkError.connectionFailure("No data attached") }
        if let validMessageModel = parseJSONError(responseData: responseData) {
            try handleMessageModel(message: validMessageModel)
        }
        return validData
    }

    private func handleMessageModel(message: MessageModel) throws {
        if let status = message.status,
            let statusCode = Int(status) {
            if statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if statusCode == 403 {
                throw NetworkError.forbidden
            }
        }
        if message.status == nil && message.message == nil {
            //throw NetworkError.unauthorized
        }
    }

    private func parseJSONError(responseData: Data?) -> MessageModel? {
        guard let validData = responseData else { return nil }
        return JSONDecoderHelper.decode(MessageModel.self, fromData: validData)
    }
}

extension NetworkService {

    // MARK: - Logging functions

    func logCall(jsonData: Data?, responseError: Error?, response: URLResponse?) {
        Logger.info("### BEGIN ###")
        if let httpResponse = response as? HTTPURLResponse {
            Logger.info("Status code: \(httpResponse.statusCode)")
        }
        Logger.info("Error: \(responseError?.localizedDescription ?? "NA")")
        guard let jsonData = jsonData else { return }
        let datastring = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        Logger.info("Data: \(datastring ?? "NA")")
        Logger.info("### END ###")
    }
}


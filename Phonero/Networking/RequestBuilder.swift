//
//  RequestBuilder.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

enum ContentType: String {
    case urlEncoded = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}

/// transforms type of Request to URLRequest
class RequestBuilder {

    static func buildUrlRequest(request: Request) -> URLRequest {
        guard let url = request.url else { fatalError("Request invalid") }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        if !request.parameters.isEmpty {
            if let contentType = request.contentType,
                contentType.contains(ContentType.urlEncoded.rawValue) {
                urlRequest.httpBody = urlEncoded(data: request.parameters)
            } else {
                let jsonData = try? JSONSerialization.data(withJSONObject: request.parameters)
                Logger.debug("Sending: \(request.parameters)")
                urlRequest.httpBody = jsonData
            }
        }
        for keyVal in request.headers {
            urlRequest.setValue(keyVal.value, forHTTPHeaderField: keyVal.key)
        }
        if request.contentType != nil {
            urlRequest.setValue(request.contentType, forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }

    private static func urlEncoded(data: [String: AnyObject]) -> Data? {
        var toArray = [String]()
        data.forEach { (key, value) in
            toArray.append("\(key)=\(value)")
        }
        let postString = toArray.joined(separator: "&")
        return postString.data(using: .utf8)
    }
}


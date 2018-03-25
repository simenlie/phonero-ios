//
//  Request.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

/// struct used by RequestBuilder to create a URLRequest
struct Request {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let parameters: [String : AnyObject]
    let headers: [String : String]
    let queryParams: [String : String]
    let contentType: String?
}

extension Request {
    var url: URL? {
        guard let url = URL(string: "\(baseURL)\(path)") else { return nil }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        var queries = [URLQueryItem]()
        queryParams.forEach { (arg) in
            let (key, value) = arg
            queries.append(URLQueryItem(name: key, value: value))
        }
        if !queryParams.isEmpty {
            urlComponents?.queryItems = queries
        }
        guard let urlComp = urlComponents else {
            return nil }
        print("Base: \(urlComp.url?.absoluteString)")

        return urlComp.url
    }
}


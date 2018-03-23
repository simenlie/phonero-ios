//
//  Router.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

protocol Router {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String : AnyObject] { get }
    var queryParams: [String: String] { get }
    var headers: [String : String] { get }
    var contentType: String? { get }
}

extension Router {
    var request: Request {
        return Request(baseURL: baseURL,
                       path: path,
                       method: method,
                       parameters: parameters,
                       headers: headers,
                       queryParams: queryParams,
                       contentType: contentType)
    }
}

//
//  JSONService.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation


struct JSONService {
    var requestable: Requestable

    /// Executes a network request via the Requestable object and decodes the json result to a Decodable class passed in
    @discardableResult
    func execute<T>(_ route: Router,
                    type: T.Type,
                    completion: @escaping (Result<T>) -> Void) -> URLSessionDataTask? where T : Decodable {
        return requestable.executeDataRequest(route: route) { (result) in
            switch result {
            case let .success(data):
                guard let codable = JSONDecoderHelper.decode(type, fromData: data) else {
                    completion(.failure(NetworkError.cannotParse))
                    return
                }
                completion(.success(codable))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

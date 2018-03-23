//
//  JSONDecoderHelper.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

class JSONDecoderHelper {

    static func decode<T>(_ type: T.Type, fromData: Data) -> T? where T: Decodable {
        let decoder = JSONDecoder()
        do {
            let usage = try decoder.decode(type, from: fromData)
            return usage
        } catch {
            print(error)
            Logger.debug(error.localizedDescription)
        }
        return nil
    }
}

class JSONEncoderHelper {
    func encodeCollection(usage: [Codable]) -> [[String: Any]]? {
        let encoder = JSONEncoder()
        do {
            let usageJSON = try encoder.encode(usage)
            let json = try JSONSerialization.jsonObject(with: usageJSON, options: .allowFragments) as? [[String: Any]]
            return json
        } catch {
            print(error)
        }
        return nil
    }
}


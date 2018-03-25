//
//  Backend.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation
import SwiftHash

struct Auth: Codable {
    let mobilenumber: String
    let name: String
}

struct Usage: Codable {
    let dataUsage: DataUsage
    enum CodingKeys: String, CodingKey {
        case dataUsage = "data_usage"
    }
}

struct DataUsage: Codable {
    let progress: Int
    let total: Int
    let progressPercent: Double

    enum CodingKeys: String, CodingKey {
        case progress
        case total
        case progressPercent = "progress_percent"
    }

    var formattedProgress: String {
        return "\(Double(progress)/1000)"
    }

    var formattedTotal: String {
        if total < 1000 {
            return "\(total)MB"
        } else {
            return "\(total/1000) GB"
        }
    }
}


class Backend {

    lazy var jsonService: JSONService = {
        return JSONService(requestable: NetworkService())
    }()

    func login(username: String, password: String, completion: @escaping (Result<Auth>) -> Void) {
        let route = APIRouter.authenticate(username: username, password: MD5(password).lowercased())
        jsonService.execute(route, type: Auth.self, completion: completion)
    }

    func getUsage(completion: @escaping (Result<Usage>) -> Void) {
        let route = APIRouter.dashboard
        jsonService.execute(route, type: Usage.self, completion: completion)
    }

}

enum APIRouter: Router {
    case authenticate(username: String, password: String)
    case dashboard

    var baseURL: String {
        return "https://apibn.phonero.net/mobileapp/"
    }

    var path: String {
        switch self {
        case .authenticate:
            return "4.1/authenticate"
        case .dashboard:
            return "4.2/getdashboard"
        }
    }

    var method: HTTPMethod {
        return .POST
    }

    var parameters: [String : AnyObject] {
        switch self {
        case .authenticate(let username, let password):
            print(password)
            return ["username": username as AnyObject,
                    "password": password as AnyObject]
        default:
            return [:]
        }
    }

    var queryParams: [String : String] {
        switch self {
        case .dashboard:
            return ["dashboardtype": "0"]
        default:
            return [:]
        }
    }

    var headers: [String : String] {
        return [:]
    }

    var contentType: String? {
        return "application/x-www-form-urlencoded"
    }
}

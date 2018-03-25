//
//  DataWorker.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

enum DataResult<Value> {
    case success(Value)
    case failure(Error)
    case loginRequired
}

class DataWorker {

    let backend = ServiceFactory().backend
    let authentication = ServiceFactory().authentication

    // MARK: Backend calls

    func fetchData(completion: @escaping (DataResult<Usage>) -> Void) {
        if authentication.requiresLogin {
            completion(.loginRequired)
        } else {
            if hasCookie {
                getDashboard(completion: completion)
            } else {
                authenticate(completion: { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.getDashboard(completion: completion)
                    }
                })
            }
        }
    }

    private func authenticate(completion: @escaping (Error?) -> Void) {
        guard let credentials = authentication.userCredentials else { return }
        backend.login(username: credentials.username, password: credentials.password, completion: { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }

    private func getDashboard(completion: @escaping (DataResult<Usage>) -> Void) {
        self.backend.getUsage { (result) in
            switch result {
            case .success(let usage):
                completion(.success(usage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helper

   private var hasCookie: Bool {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == "BNAPI2" {
                    return true
                }
            }
        }
        return false
    }
    
}

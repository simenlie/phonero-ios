//
//  KeychainAuthentication.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation
import KeychainAccess

struct UserCredentials {
    let username: String
    let password: String
}

protocol Authentication {
    var requiresLogin: Bool { get }
    var userCredentials: UserCredentials? { get }
    func store(credentials: UserCredentials)
}

/// A Keychain implementation of the Authentication protocol
class KeychainAuthentication: Authentication {

    var userCredentials: UserCredentials? {
        guard let username = storedToken(key: Keys.username),
            let password = storedToken(key: Keys.password) else { return nil }
        return UserCredentials(username: username, password: password)
    }


    private struct Keys {
        static let subscriberId = "subscriberId"
        static let customerType = "customerType"
        static let username = "username"
        static let password = "password"
        static let accessToken = "accessToken"
        static let accessTokenExpiresAt = "accessTokenExpiresAt"
    }

    private let service: String

    var requiresLogin: Bool {
        return userCredentials == nil
    }

    private lazy var keychain: Keychain = {
        return Keychain(service: service)
            .synchronizable(true)
            .accessibility(.whenUnlocked) //.afterFirstUnlock for background
    }()

    init(service: String) {
        self.service = service
    }

    func store(credentials: UserCredentials) {
        store(token: credentials.username, forKey: Keys.username)
        store(token: credentials.password, forKey: Keys.password)
    }

    func reset() {
        let tempUsername = userCredentials?.username
        do {
            try keychain.removeAll()
            if let username = tempUsername {
                self.store(credentials: UserCredentials(username: username, password: ""))
            }
        }
        catch{
            Logger.error("Error removing credentials: \(error)")
        }
    }

    // MARK: - Helper

    private func store(token: String, forKey: String) {
        do {
            try keychain.set(token, key: forKey)
        } catch {
            Logger.error("Error storing token in keychain: \(error)")
        }
    }

    private func storedToken(key: String) -> String? {
        do {
            return try keychain.get(key)
        } catch {
            Logger.error("Error retrieving token from keychain: \(error)")
        }
        return nil
    }
}


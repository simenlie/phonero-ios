//
//  ServiceFactory.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

class ServiceFactory {
    var backend: Backend {
        return Backend()
    }

    var authentication: Authentication {
        return KeychainAuthentication(service: "no.liite.phonero")
    }
}

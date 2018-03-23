//
//  Logger.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import Foundation

protocol Loggable {
    func log()
}

enum LogLevel: String {
    case error, debug, warn, info
}

struct Logger {

    private static func log(logLevel: LogLevel, message: String) {
        Logger.write(level: logLevel, message: message)
    }

    static func debug(_ message: String) {
        Logger.log(logLevel: .debug, message: message)
    }

    static func error(_ message: String) {
        Logger.log(logLevel: .error, message: message)
    }

    static func warn(_ message: String) {
        Logger.log(logLevel: .warn, message: message)
    }

    static func info(_ message: String) {
        Logger.log(logLevel: .info, message: message)
    }

    static func write(level: LogLevel, message: String) {
        if level == .debug {
            #if Dev
                print("\(level.rawValue.uppercased()): \(message)")
            #endif
        } else {
            print("\(level.rawValue.uppercased()): \(message)")
        }
    }
}


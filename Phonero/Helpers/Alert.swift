//
//  Alert.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

enum AlertInfo {
    case login
}

struct Alert {

    //For a error
    static func presentAlert(for error: Error?,
                             presenter: UIViewController,
                             info: AlertInfo? = nil,
                             okHandler: ((UIAlertAction) -> Void)? = nil,
                             completion: (() -> Void)? = nil) {
        let message: String

        if let error = error {
            if case NetworkError.noInternet = error {
                message = "Du har ikke internett"
            } else if let alertInfo = info {
                switch alertInfo {
                case .login:
                    message = "Brukernavn eller passord feil"
                }
            }
            else {
                message = "generic_error"
            }
        } else {
            message = "generic_error"
        }

        let ac = UIAlertController(title: "Oisann", message: message, preferredStyle: .alert)
        //ac.view.tintColor = PhoneroColor.darkBlue
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        ac.addAction(cancelAction)

        presenter.present(ac, animated: true, completion: completion)
    }
}

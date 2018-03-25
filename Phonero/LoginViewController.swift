//
//  LoginViewController.swift
//  Phonero
//
//  Created by Petter Holstad Wright on 23.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let backend = Backend()
    let authentication = ServiceFactory().authentication

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginAction(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text, let password = passwordTextField.text, (phoneNumber.count == 8 && password != "") {
            self.login(username: phoneNumber, password: password)
        } else {
            let alert = UIAlertController(title: "Fyll ut felter riktig", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func login(username: String, password: String) {
        backend.login(username: username,
                      password: password,
                      completion: { (result) in
                        switch result {
                        case .success(let auth):
                            Logger.debug("Auth: \(auth)")
                            self.authentication.store(credentials: UserCredentials(username: username, password: password))
                            self.performSegue(withIdentifier: "UnwindSegue", sender: self)
                        case .failure(let error):
                            Logger.debug(error.localizedDescription)
                            Alert.presentAlert(for: error, presenter: self)
                        }
        })
    }


}

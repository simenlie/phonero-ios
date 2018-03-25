//
//  ViewController.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

class ServiceFactory {
    var backend: Backend {
        return Backend()
    }

    var authentication: Authentication {
        return KeychainAuthentication(service: "no.liite.phonero")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    let backend = ServiceFactory().backend
    let authentication = ServiceFactory().authentication

    lazy var uiRefreshControl = {
        return UIRefreshControl()
    }()

    @IBOutlet weak var usageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usageLabel.text = "Henter data"
        configureRefreshControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }

    func configureRefreshControl() {
        uiRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.scrollView.addSubview(uiRefreshControl)
    }

    @objc func refresh() {
        fetchData()
    }

    @IBAction func unwindLoginSegue(_ sender: UIStoryboardSegue) {
       
    }

    func fetchData() {
        if authentication.requiresLogin {
            self.performSegue(withIdentifier: "ShowLoginSegue", sender: self)
        } else {
            if hasCookie {
                getDashboard()
            } else {
                authenticate {
                    self.getDashboard()
                }
            }
        }
    }

    func getDashboard() {
        self.backend.getUsage { (result) in
            switch result {
            case .success(let usage):
                Logger.debug("Usage: \(usage)")
                self.usageLabel.text = "\(usage.dataUsage.formattedProgress)/\(usage.dataUsage.formattedTotal)"
            case .failure(let error):
                Logger.debug(error.localizedDescription)
            }
            self.uiRefreshControl.endRefreshing()
        }
    }

    func authenticate(completion: @escaping () -> Void) {
        guard let credentials = authentication.userCredentials else { return }
        backend.login(username: credentials.username, password: credentials.password, completion: { (result) in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                self.uiRefreshControl.endRefreshing()
                Alert.presentAlert(for: error, presenter: self)
            }
        })
    }

    var hasCookie: Bool {
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


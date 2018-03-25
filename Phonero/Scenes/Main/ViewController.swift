//
//  ViewController.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var percentageUsedLabel: UILabel!
    @IBOutlet weak var gbUsedLabel: UILabel!
    @IBOutlet weak var totalGbLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dataView: UIView!

    lazy var circularView: CircularProgressView = {
        let view = CircularProgressView(lineWidth: 20)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var uiRefreshControl = {
        return UIRefreshControl()
    }()

    let backend = ServiceFactory().backend
    let authentication = ServiceFactory().authentication

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureCiruclarView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }

    func configureCiruclarView() {
        dataView.addSubview(circularView)
        NSLayoutConstraint.activate([
            circularView.topAnchor.constraint(equalTo: dataView.topAnchor),
            circularView.leadingAnchor.constraint(equalTo: dataView.leadingAnchor),
            circularView.trailingAnchor.constraint(equalTo: dataView.trailingAnchor),
            circularView.bottomAnchor.constraint(equalTo: dataView.bottomAnchor)
            ])
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

    func dataFetched(usage: Usage) {
        Logger.debug("Usage: \(usage)")
        circularView.animateWith(progress: usage.dataUsage.progressPercent/100)
        self.gbUsedLabel.text = "\(usage.dataUsage.formattedProgress) av"
        self.totalGbLabel.text = usage.dataUsage.formattedTotal
        self.percentageUsedLabel.text = "\(Int(round(usage.dataUsage.progressPercent))) %"
    }

    // MARK: Backend calls

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

    func getDashboard() {
        self.backend.getUsage { (result) in
            switch result {
            case .success(let usage):
                self.dataFetched(usage: usage)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
            }
            self.uiRefreshControl.endRefreshing()
        }
    }

    // MARK: - Helper

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


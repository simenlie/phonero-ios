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

    let dataWorker = DataWorker()

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
        circularView.update(progress: usage.dataUsage.progressPercent/100)
        self.gbUsedLabel.text = "\(usage.dataUsage.formattedProgress) av"
        self.totalGbLabel.text = usage.dataUsage.formattedTotal
        self.percentageUsedLabel.text = "\(Int(round(usage.dataUsage.progressPercent))) %"
    }

    // MARK: Backend calls

    func fetchData() {
        self.dataWorker.fetchData { (result) in
            self.uiRefreshControl.endRefreshing()
            switch result {
            case .success(let usage):
                self.dataFetched(usage: usage)
            case .failure(let error):
                Alert.presentAlert(for: error, presenter: self)
            case .loginRequired:
                self.performSegue(withIdentifier: "ShowLoginSegue", sender: self)
            }
        }
    }

}


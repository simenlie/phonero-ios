//
//  TodayViewController.swift
//  Databruk
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    let dataWorker = DataWorker()

    @IBOutlet weak var failedView: UIView!
    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var usageLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var totalUsageLabel: UILabel!
    lazy var circularView: CircularProgressView = {
        let view = CircularProgressView(lineWidth: 10, lineBackgroundColor: UIColor(red: 52, green: 40, blue: 44).withAlphaComponent(0.4))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

        
    @IBOutlet weak var dataView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        configureCiruclarView()
        failedView.isHidden = true
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        dataWorker.fetchData { (result) in
            switch result {
            case .success(let usage):
                self.dataFetched(usage: usage)
                completionHandler(NCUpdateResult.newData)
            case .failure(let error):
                self.failedView.isHidden = false
                self.failedLabel.text = "Kan ikke laste inn"
                completionHandler(NCUpdateResult.failed)
            case .loginRequired:
                self.failedView.isHidden = false
                self.failedLabel.text = "Du må logge inn i appen først"
                completionHandler(NCUpdateResult.failed)
            }
        }
    }
    
}

extension TodayViewController {

    func dataFetched(usage: Usage) {
        failedView.isHidden = true
        circularView.update(progress: usage.dataUsage.progressPercent/100, animated: false)
        self.percentLabel.text = "\(Int(round(usage.dataUsage.progressPercent)))%"
        self.usageLabel.text = "\(usage.dataUsage.formattedProgress) av"
        self.totalUsageLabel.text = usage.dataUsage.formattedTotal
    }

}

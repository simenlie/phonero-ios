//
//  ViewController.swift
//  Phonero
//
//  Created by Simen Lie on 22.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let backend = Backend()

    @IBOutlet weak var usageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usageLabel.text = "Henter data"
        fetchData()
    }

    func fetchData() {
        backend.getUsage { (result) in
            switch result {
            case .success(let usage):
                Logger.debug("Usage: \(usage)")
                self.usageLabel.text = "\(usage.dataUsage.formattedProgress)/\(usage.dataUsage.formattedTotal)"
            case .failure(let error):
                Logger.debug(error.localizedDescription)
            }
        }
    }

}

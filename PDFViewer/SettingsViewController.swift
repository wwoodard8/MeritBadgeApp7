//
//  SettingsViewController.swift
//  PDFViewer
//
//  Created by Will Woodard on 4/13/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var downloadSwitch: UISwitch!
    
    @IBAction func downloadSwitchTapped(_ sender: Any) {
        print("download button tapped")
        userDefaults.set(downloadSwitch.isOn, forKey: "mySwitchValue")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        downloadSwitch.isOn = userDefaults.bool(forKey: "mySwitchValue")

    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is MeritBadgeLIstTableViewController
        {
            let vc = segue.destination as? MeritBadgeLIstTableViewController
            vc?.downloadOnly = downloadSwitch.isOn
        }
    }

}

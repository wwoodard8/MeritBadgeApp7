//
//  MeritBadgeLIstTableViewController.swift
//  PDFViewer
//
//  Created by Will Woodard on 2/9/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//

import UIKit

class MeritBadgeLIstTableViewController: UITableViewController {
    
    var meritbadges: [MeritBadge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        meritbadges = createArray()
    }
    
    func createArray () -> [MeritBadge] {
        
        var tempMeritBadges: [MeritBadge] = []
        
        let meritbadge1 = MeritBadge(image: UIImage(named: "dogcare")!, title: "Dog Care")
        let meritbadge2 = MeritBadge(image: UIImage(named: "radio")!, title: "Radio")
        
        tempMeritBadges.append(meritbadge1)
        tempMeritBadges.append(meritbadge2)

        return tempMeritBadges
    }

    
}

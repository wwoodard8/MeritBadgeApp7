//
//  MeritBadgeLIstTableViewController.swift
//  PDFViewer
//
//  Created by Will Woodard on 2/9/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//

import UIKit

class MeritBadgeLIstTableViewController: UITableViewController {
    
    @IBOutlet var MeritBadgetableview: UITableView!
    @IBOutlet weak var LocalSaveSwitch: UISwitch!
    
    var meritbadges: [MeritBadge] = []
    var whichBadge = ""
    var pdfURL: URL!


    override func viewDidLoad() {
        super.viewDidLoad()
        meritbadges = createArray()
        
        
    }
    
    func createArray () -> [MeritBadge] {
        
        var tempMeritBadges: [MeritBadge] = []
        
        let meritbadge1 = MeritBadge(image: UIImage(named: "dogcare")!, title: "Dog Care", filename: "dogcaredown")
        let meritbadge2 = MeritBadge(image: UIImage(named: "radio")!, title: "Radio", filename: "radio")
        let meritbadge3 = MeritBadge(image: UIImage(named: "firstaid")!, title: "First Aid", filename: "firstaid")

        tempMeritBadges.append(meritbadge1)
        tempMeritBadges.append(meritbadge2)
        tempMeritBadges.append(meritbadge3)

        return tempMeritBadges
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
}


extension MeritBadgeLIstTableViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meritbadges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meritbadge = meritbadges[indexPath.row]
        print(meritbadge.title)
        print(indexPath.row)
        
        let fileManager = FileManager.default
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeritBadgeCell") as! MeritBadgeCell
        
        //tableView.backgroundColor = UIColor.gray
        //cell.backgroundColor = UIColor.gray
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        
        //cell.layer.borderColor = UIColor.black as! CGColor
        
        cell.setMeritBadge(meritbadge: meritbadge)
        
        let switchObj = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
        
        switchObj.tag = indexPath.row
        
        if fileManager.fileExists(atPath: (NSHomeDirectory() + "/Library/Caches/" + meritbadge.filename + ".pdf")) {
            print(meritbadge.title + " exists")
            switchObj.isOn = true

        } else {
            print(meritbadge.title + "doesnt exists")
            switchObj.isOn = false

        }

        switchObj.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
        cell.accessoryView = switchObj
        
        return cell
    }
    
     @objc func toggle(_ sender: UISwitch) {
        
        print(NSHomeDirectory())
        print(sender.tag)
        
        let filename = meritbadges[sender.tag].filename
        
        if sender.isOn {
            
            guard let url = URL(string: "https://willwoodard.com/meritbadge/" + filename + ".pdf") else { return }
            
            let urlSession = URLSession(configuration: .default, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue())
            
            let downloadTask = urlSession.downloadTask(with: url)
            
            downloadTask.resume()
            
            createSpinnerView()
                        
        }
        else {
            let fileManager = FileManager.default
            let removeStr = NSHomeDirectory() + "/Library/Caches/" + filename + ".pdf"
            if fileManager.fileExists(atPath: removeStr) {
                try! fileManager.removeItem(atPath: removeStr)
            } else {
                print("file does not exist")
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected: \(indexPath.row)")
        print(meritbadges[indexPath.row].title)
        print(meritbadges[indexPath.row].filename)

        self.whichBadge = meritbadges[indexPath.row].filename
        performSegue(withIdentifier: "PDFSegue", sender: self)
    }

    
    //override func tableView(_ tableView: UITableView, titleForHeaderInSection
    //                           section: Int) -> String? {
    //   return "Tap badge to view. Slide to download."
    //
    //}
    
    //override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //    return 0.000001;
    //}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.showBadgeName = self.whichBadge
        vc.showpdfURL = self.pdfURL
    }
    
    
}

extension MeritBadgeLIstTableViewController:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        // create destination URL with the original pdf name
        print(NSHomeDirectory())
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            //self.testPass = destinationURL.absoluteString
            self.pdfURL = destinationURL
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
}

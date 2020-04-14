//
//  MeritBadgeLIstTableViewController.swift
//  PDFViewer
//
//  Created by Will Woodard on 2/9/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//  Do you see me?

import UIKit

class MeritBadgeLIstTableViewController: UITableViewController {
    
    @IBOutlet var MeritBadgetableview: UITableView!
    @IBOutlet weak var LocalSaveSwitch: UISwitch!
    
    var meritbadges: [MeritBadge] = []
    var whichBadge = ""
    var pdfURL: URL!
    var downloadOnly = Bool()
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        meritbadges = createArray()
        
        //create the settings button programatically
        let button = UIButton(frame: CGRect(x: self.view.frame.size.width - 80, y: 0, width: 60, height: 50))
        button.backgroundColor = .white
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 16.0)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)
        
        }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        performSegue(withIdentifier: "settingsView", sender: nil)
    }

    func createArray () -> [MeritBadge] {
        
        var tempMeritBadges: [MeritBadge] = []
        var tempMeritBadges2: [MeritBadge] = []
        
        let meritbadge1 = MeritBadge(image: UIImage(named: "dogcare")!, title: "Dog Care", filename: "dogcaredown")
        let meritbadge2 = MeritBadge(image: UIImage(named: "radio")!, title: "Radio", filename: "radio")
        let meritbadge3 = MeritBadge(image: UIImage(named: "firstaid")!, title: "First Aid", filename: "firstaid")
        
        tempMeritBadges.append(meritbadge1)
        tempMeritBadges.append(meritbadge2)
        tempMeritBadges.append(meritbadge3)
        
        //loop through all array entries and check for local presence of merit badge pdf, set localfile to true if present
        let fileManager = FileManager.default
        for tempMeritBadge in tempMeritBadges {
            
            let fileStr = NSHomeDirectory() + "/Library/Caches/" + tempMeritBadge.filename + ".pdf"
            if fileManager.fileExists(atPath: fileStr) {
                tempMeritBadge.localfile = true
                tempMeritBadges2.append(tempMeritBadge)
            } else {
                tempMeritBadge.localfile = false
            }

        }
        
        //sort array by stitle
        tempMeritBadges.sort { $0.title < $1.title }
        
        //then sort by if the book is downloaded
        let downloadOnly = defaults.bool(forKey: "mySwitchValue")
        
        if downloadOnly {
            print("download is true ")
            tempMeritBadges.sort { $0.localfile && !$1.localfile }
            return tempMeritBadges2
        }
        else{
            print ("download is false")
            return tempMeritBadges
        }
        
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
        
        //tableView.backgroundColor = UIColor.white
        //cell.backgroundColor = UIColor.gray
        //cell.layer.cornerRadius = 10
        //cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        
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
        let title = meritbadges[sender.tag].title
        
        if sender.isOn {
            
            //show alert dialog asking user if they want to download the Merit Badge book
            let downloadalert = UIAlertController(title: "Do you wish to download the " + title + " merit badge book?", message: "A copy will be downloaded to this device.", preferredStyle: .alert)

            downloadalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                sender.setOn(false, animated: true)
            }))
            downloadalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
                guard let url = URL(string: "https://willwoodard.com/meritbadge/" + filename + ".pdf") else { return }
            
                let urlSession = URLSession(configuration: .default, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue())
            
                let downloadTask = urlSession.downloadTask(with: url)
            
                downloadTask.resume()
            
                self.createSpinnerView()
                
           }))
            
            self.present(downloadalert, animated: true)
            
        }
        else {
            //show alert dialog asking user if they want to delete the local Merit Badge book
            let deletealert = UIAlertController(title: "Do you wish to delete your copy of the " + title + " merit badge book?", message: "Your copy will be removed from this device.", preferredStyle: .alert)

            deletealert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                sender.setOn(true, animated: true)
            }))
            deletealert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                let fileManager = FileManager.default
                let removeStr = NSHomeDirectory() + "/Library/Caches/" + filename + ".pdf"
                if fileManager.fileExists(atPath: removeStr) {
                    try! fileManager.removeItem(atPath: removeStr)
                    self.createSpinnerView()
 
                } else {
                    print("file does not exist")
                }
            }))
                
            self.present(deletealert, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("row selected: \(indexPath.row)")
        print(meritbadges[indexPath.row].title)
        print(meritbadges[indexPath.row].filename)
        
        self.whichBadge = meritbadges[indexPath.row].filename
        performSegue(withIdentifier: "PDFSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue id")
        print(segue.identifier)
        if segue.identifier == "SettingsView"
        {
            print ("in settingsview")
        }
        else if segue.identifier == "PDFSegue"
        {
            let vc = segue.destination as! ViewController
            vc.showBadgeName = self.whichBadge
            vc.showpdfURL = self.pdfURL
        }
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

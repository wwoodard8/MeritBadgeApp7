//
//  MainViewController.swift
//  PDFViewer
//
//  Created by Will Woodard on 2/4/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//

import UIKit
import PDFKit

class MainViewController: UIViewController {

    var whichBadge = ""
    var pdfView = PDFView()
    var pdfURL: URL!
    
    @IBOutlet weak var DogCareSaveLocal: UISwitch!
    @IBOutlet weak var DogCareSaveLocalLabel: UILabel!
    @IBOutlet weak var RadioSaveLocal: UISwitch!
    @IBOutlet weak var RadioSaveLocalLabel: UILabel!
    @IBOutlet weak var errorLogLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //check for existance of local books, set switches accordingly
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: (NSHomeDirectory() + "/Library/Caches/dogcare.pdf")) {
            print("dogcare exists")
            DogCareSaveLocal.setOn(true, animated: true)
            DogCareSaveLocalLabel.text = "Local"

        } else {
            print("dogcare doesnt exists")
            DogCareSaveLocal.setOn(false, animated: true)
            DogCareSaveLocalLabel.text = "Web"

        }
        if fileManager.fileExists(atPath: (NSHomeDirectory() + "/Library/Caches/radio.pdf")) {
            print("radio exists")
            RadioSaveLocal.setOn(true, animated: true)
            RadioSaveLocalLabel.text = "Local"

        } else {
            print("radio doesn't exist")
            RadioSaveLocal.setOn(false, animated: true)
            RadioSaveLocalLabel.text = "Web"

        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func DogCareAction(_ sender: Any) {
        self.whichBadge = "dogcare"
        //performSegue(withIdentifier: "DogCareSegue", sender: self)
    }
    
    @IBAction func RadioAction(_ sender: Any) {
        self.whichBadge = "radio"
        //performSegue(withIdentifier: "RadioSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! ViewController
        vc.showBadgeName = self.whichBadge
        vc.showpdfURL = self.pdfURL
    }
    
    //These actions take the selected merit badge PDF and save it locally
    @IBAction func DogCareSaveLocal(_ sender: Any) {
        if DogCareSaveLocal.isOn {
            //Set Label
            DogCareSaveLocalLabel.text = "Local"
            
            guard let url = URL(string: "https://willwoodard.com/meritbadge/dogcare.pdf") else { return }
            
            let urlSession = URLSession(configuration: .default, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue())
            
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
            
        }
        else {
            DogCareSaveLocalLabel.text = "Web"
            let fileManager = FileManager.default
            let removeStr = NSHomeDirectory() + "/Library/Caches/dogcare.pdf"
            if fileManager.fileExists(atPath: removeStr) {
                try! fileManager.removeItem(atPath: removeStr)
            } else {
                print("file does not exist")
            }
        }
    }
    
    @IBAction func RadioSaveLocal(_ sender: Any) {
        if RadioSaveLocal.isOn {
            //Set Label
            RadioSaveLocalLabel.text = "Local"
            
            guard let url = URL(string: "https://willwoodard.com/meritbadge/radio.pdf") else { return }
            
            let urlSession = URLSession(configuration: .default, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue())
            
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
            
        }
        else {
            RadioSaveLocalLabel.text = "Web"
            let fileManager = FileManager.default
            let removeStr = NSHomeDirectory() + "/Library/Caches/radio.pdf"
            if fileManager.fileExists(atPath: removeStr) {
                try! fileManager.removeItem(atPath: removeStr)
            } else {
                print("file does not exist")
            }
        }

    }
    
    
}

extension MainViewController:  URLSessionDownloadDelegate {
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

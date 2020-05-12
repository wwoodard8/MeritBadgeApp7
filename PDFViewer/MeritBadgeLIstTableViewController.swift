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
    
    //vars used for merit badge list
    var meritbadges: [MeritBadge] = []
    var whichBadge = ""
    var pdfURL: URL!
    var downloadOnly = Bool()
    
    let defaults = UserDefaults.standard
    
    //initialization for search bar
    let searchController = UISearchController(searchResultsController: nil)
    var filteredBadges: [MeritBadge] = []
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meritbadges = createArray()
        
        //create the SETTINGS BUTTON programatically
        let button = UIButton(frame: CGRect(x: self.view.frame.size.width - 80, y: -100, width: 60, height: 50))
        button.backgroundColor = .white
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 16.0)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        //self.view.addSubview(button)
        
        //set things up for the creation of the SEARCH BAR
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Merit Badges"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        }
    
    
    //func that moves to settings view if you tap the settings button
    @objc func buttonAction(sender: UIButton!) {
        //print("Button tapped")
        performSegue(withIdentifier: "settingsView", sender: nil)
        //defaults.set(false, forKey: "mySwitchValue")
        //meritbadges = createArray()
        //tableView.setNeedsDisplay()
    }
    

    //func that fills the merit badge array
    func createArray () -> [MeritBadge] {
        
        //fills the FILE NAME and PRINTED TITLE of the merit badge books
        let meritBadgeName: [[String]] =
        [
        ["americanbusiness", "American Business"],
        ["americancultures", "American Cultures"],
        ["americanheritage", "American Heritage"],
        ["americanlabor", "American Labor"],
        ["animalscience", "Animal Science"],
        ["archery", "Archery"],
        ["architechture", "Architechture"],
        ["art", "Art"],
        ["astronomy", "Astronomy"],
        ["athletics", "Athletics"],
        ["dogcare", "Dog Care"],
        ["radio", "Radio"],
        ["firstaid", "First Aid"],
        ["automotivemaintenance", "Automotive Maintenance"],
        ["aviation", "Aviation"],
        ["backpacking", "Backpacking"],
        ["basketry", "Basketry"],
        ["birdstudy", "Bird Study"],
        ["camping", "Camping"],
        ["canoeing", "Canoeing"],
        ["chemistry", "Chemistry"],
        ["chess", "Chess"],
        ["citizencom", "Citizenship in the Community"],
        ["citizennat", "Citizenship in the Nation"],
        ["citizenshipwor", "Citizenship in the World"],
        ["climbing", "Climbing"],
        ["coincollecting", "Coin Collecting"],
        ["collections", "Collection"],
        ["communication", "Communication"],
        ["compositematerials", "Composite Materials"],
        ["computers", "Computers"],
        ["cooking", "Cooking"],
        ["crimeprevention", "Crime Prevention"],
        ["stampcollecting", "Stamp Collecting"],
        ["cycling", "Cycling"],
        ["dentistry", "Dentistry"],
        ["digitaltechnology", "Digital Technology"],
        ["disabilitiesawareness", "Disabilities Awareness"],
        ["electricity", "Electricity"],
        ["electronics", "Electronics"],
        ["emergencypreparedness", "Emergency Preparedness"],
        ["energy", "Energy"],
        ["engineering", "Engineering"],
        ["entrepeneurship", "Entrepeneurship"],
        ["environmentalscience", "Environmental Science"],
        ["exploration", "Exploration"],
        ["familylife", "Family Life"],
        ["farmmechanics", "Farm Mechanics"],
        ["fingerprinting", "Fingerprinting"],
        ["firesafety", "Fire Safety"],
        ["fishwildlife", "Fish and Wildlife"],
        ["flyfishing", "Fly Fishing"],
        ["forestry", "Forestry"],
        ["gamedesign", "Game Design"],
        ["gardening", "Gardening"],
        ["genealogy", "Genealogy"],
        ["geocaching", "Geocaching"],
        ["geology", "Geology"],
        ["golf", "Golf"],
        ["graphicarts", "Graphic Arts"],
        ["hiking", "Hiking"],
        ["homerepairs", "Home Repairs"],
        ["horsemanship", "Horsemanship"],
        ["insectstudy", "Insect Study"],
        ["inventing", "Inventing"],
        ["journalism", "Journalism"],
        ["kayaking", "Kayaking"],
        ["law", "Law"],
        ["leatherwork", "Leatherwork"],
        ["lifesaving", "Lifesaving"],
        ["mammalstudy", "Mammal Study"],
        ["medicine", "Medicine"],
        ["metalwork", "Metalwork"],
        ["mininginsociety", "Mining in Society"],
        ["modeldesign", "Model Design"],
        ["motorboating", "Motorboating"],
        ["moviemaking", "Moviemaking"],
        ["musicandbugling", "Music and Bugling"],
        ["nature", "Nature"],
        ["nuclearscience", "Nuclear Science"],
        ["oceanography", "Oceanography"],
        ]
        //print(meritBadgeName[0][1]) is "American Business"
        
        var tempMeritBadges: [MeritBadge] = []
        var tempMeritBadges2: [MeritBadge] = []
        
        //creates the MERIT BADGE ARRAY
        for meritBadge in meritBadgeName {
            
            //print(meritBadge[0])
            let fullMeritBadgeInfo = MeritBadge(image: UIImage(named: meritBadge[0])!, title: meritBadge[1], filename: meritBadge[0])
            tempMeritBadges.append(fullMeritBadgeInfo)

        }

        //loop through all array entries and check for LOCAL PRESENCE of merit badge pdf, set localfile to true if present
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
        
        //sort array by TITLE
        tempMeritBadges.sort { $0.title < $1.title }
        
        //then sort by if the book is DOWNLOADED
        let downloadOnly = defaults.bool(forKey: "mySwitchValue")
        
        if downloadOnly {
            //print("download is true ")
            tempMeritBadges.sort { $0.localfile && !$1.localfile }
            return tempMeritBadges2
        }
        else{
            //print ("download is false")
            return tempMeritBadges
        }
        
    }
    
    
    //creates the SPINNY overlay when downloading is going on
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
    
    
    //func that filters the list by the letters the user types in the search box
    func filterContentForSearchText(_ searchText: String,
                                    category: MeritBadge.Type? = nil) {
        filteredBadges = meritbadges.filter { (meritbadges: MeritBadge) -> Bool in
        return meritbadges.title.lowercased().contains(searchText.lowercased())
      }
      
      MeritBadgetableview.reloadData()
    }
    
}

extension MeritBadgeLIstTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredBadges.count
        }
          
        return meritbadges.count

    }
    
    //func that takes the merit badge array and fills the listview
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meritbadge = meritbadges[indexPath.row]
        //print(meritbadge.title)
        //print(indexPath.row)
        
        let fileManager = FileManager.default
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeritBadgeCell") as! MeritBadgeCell
        let currMeritBadges: MeritBadge
        
        if isFiltering {
            currMeritBadges = filteredBadges[indexPath.row]
        } else {
            currMeritBadges = meritbadges[indexPath.row]
        }
        
        //tableView.backgroundColor = UIColor.white
        //cell.backgroundColor = UIColor.gray
        //cell.layer.cornerRadius = 10
        //cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        
        cell.setMeritBadge(meritbadge: currMeritBadges)
        
        let switchObj = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
        
        switchObj.tag = indexPath.row
        
        if fileManager.fileExists(atPath: (NSHomeDirectory() + "/Library/Caches/" + currMeritBadges.filename + ".pdf")) {
            //print(currMeritBadges.title + " exists")
            switchObj.isOn = true

        } else {
            //print(currMeritBadges.title + "doesnt exists")
            switchObj.isOn = false

        }

        switchObj.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
        cell.accessoryView = switchObj
        
        return cell
    }
    
    //func that downloads a pdf if you toggle the switch on the left of each list entry
     @objc func toggle(_ sender: UISwitch) {
        
        //print(NSHomeDirectory())
        //print(sender.tag)
        

        var filename = meritbadges[sender.tag].filename
        var title = meritbadges[sender.tag].title
        
        if isFiltering {
            filename = filteredBadges[sender.tag].filename
            title = filteredBadges[sender.tag].title
        }
        
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
        
        let currMeritBadges: MeritBadge
        
        if isFiltering {
            currMeritBadges = filteredBadges[indexPath.row]
        } else {
            currMeritBadges = meritbadges[indexPath.row]
        }
        
        //print("row selected: \(indexPath.row)")
        //print(currMeritBadges.title)
        //print(currMeritBadges.filename)
        
        self.whichBadge = currMeritBadges.filename
        performSegue(withIdentifier: "PDFSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("segue id")
        //print(segue.identifier)
        if segue.identifier == "SettingsView"
        {
            //print ("in settingsview")
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
        
        //print("downloadLocation:", location)
        // create destination URL with the original pdf name
        //print(NSHomeDirectory())
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


extension MeritBadgeLIstTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

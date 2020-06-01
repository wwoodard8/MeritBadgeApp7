
//  Copyright © 2018 Todd Kramer. All rights reserved.

import UIKit
import PDFKit

class ViewController: UIViewController {


    // MARK: - Outlets

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfThumbnailView: PDFThumbnailView!
    @IBOutlet weak var sidebarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Constants

    let thumbnailDimension = 44
    //let pdfURL = Bundle.main.url(forResource: "radio", withExtension: "pdf")
    let animationDuration: TimeInterval = 0.25
    let sidebarBackgroundColor = UIColor(named: "SidebarBackgroundColor")
    
    var showBadgeName = ""
    var showtestPass = ""
    var showpdfURL: URL!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        addObservers()
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.scalePDFViewToFit()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    deinit {
        removeObservers()
    }

    // MARK: - Setup

    func setup() {
        setupPDFView()
        setupThumbnailView()
        loadPDF()
    }

    func setupPDFView() {
        pdfView.autoScales = true
    }

    func setupThumbnailView() {
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.thumbnailSize = CGSize(width: thumbnailDimension, height: thumbnailDimension)
        pdfThumbnailView.backgroundColor = sidebarBackgroundColor
    }

    func loadPDF() {
        print(showBadgeName)
        print(showpdfURL)
        
        let pw = "U2UaMFw5mSZsh95P"
        var locked = false
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: (NSHomeDirectory() + "/Library/Caches/" + showBadgeName + ".pdf")) {
            //errorLabel.text = "it's here"
            //build the url of the selected book from NSHomeDirectory + /Library/Caches/{showBadgeName}.pdf
            let fullPathStr = ("file://" + NSHomeDirectory() + "/Library/Caches/" + showBadgeName + ".pdf")
            print(fullPathStr)
            //create full book path
            let fullurl = URL(string: fullPathStr)
            print(fullurl)
            //show pdf from cache
            if let document = PDFDocument(url: fullurl!) {
                document.unlock(withPassword: pw)
                pdfView.document = document
            }
        }
        else {
            //errorLabel.text = "it ain't here"
            //create URL from string
            guard let url = URL(string: "https://willwoodard.com/meritbadge/" + showBadgeName + ".pdf") else { return }
            if let document = PDFDocument(url: url) {
                if document.isLocked {
                    locked = document.unlock(withPassword: pw)
                }
                pdfView.document = document
            }

        }
        resetNavigationButtons()
    }

    // MARK: - Notifications

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetNavigationButtons), name: .PDFViewPageChanged, object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @IBAction func sidebarTapped(_ sender: Any) {
        toggleSidebar()
    }

    @IBAction func resetTapped(_ sender: Any) {
        scalePDFViewToFit()
    }

    @IBAction func previousTapped(_ sender: Any) {
        pdfView.goToPreviousPage(sender)
    }

    @IBAction func nextTapped(_ sender: Any) {
        pdfView.goToNextPage(sender)
    }

    // MARK: - Logic

    func toggleSidebar() {
        let thumbnailViewWidth = pdfThumbnailView.frame.width
        let screenWidth = UIScreen.main.bounds.width
        let multiplier = thumbnailViewWidth / (screenWidth - thumbnailViewWidth) + 1.0
        let isShowing = sidebarLeadingConstraint.constant == 0
        let scaleFactor = pdfView.scaleFactor
        UIView.animate(withDuration: animationDuration) {
            self.sidebarLeadingConstraint.constant = isShowing ? -thumbnailViewWidth : 0
            self.pdfView.scaleFactor = isShowing ? scaleFactor * multiplier : scaleFactor / multiplier
            self.view.layoutIfNeeded()
        }
    }

    func scalePDFViewToFit() {
        UIView.animate(withDuration: animationDuration) {
            self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit
            self.view.layoutIfNeeded()
        }
    }

    @objc func resetNavigationButtons() {
        previousButton.isEnabled = true
        nextButton.isEnabled = true
    }

}


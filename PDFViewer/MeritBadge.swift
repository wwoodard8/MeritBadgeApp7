//
//  MeritBadge.swift
//  PDFViewer
//
//  Created by Will Woodard on 2/9/20.
//  Copyright © 2020 Todd Kramer. All rights reserved.
//

import Foundation
import UIKit

class MeritBadge {
    
    var image: UIImage
    var title: String
    var filename: String
    var localfile: Bool
    
    init(image: UIImage, title: String, filename: String) {
        self.image = image
        self.title = title
        self.filename = filename
        self.localfile = false
    }
}

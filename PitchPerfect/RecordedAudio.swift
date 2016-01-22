//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Abdul-Wasai Wasim on 1/21/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathURL: NSURL?
    var title: String?
    
    init(filePathURL: NSURL, title: String) {
        self.filePathURL = filePathURL
        self.title = title
    }
}
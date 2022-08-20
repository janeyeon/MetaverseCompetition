//
//  String.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/20.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation


extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }

  }

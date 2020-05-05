//
//  utilities.swift
//  UIBuilderProject
//
//  Created by student on 4/12/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//

import Foundation
extension String {
    func capitalizingFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    mutating func capitalizeFirst() {
        self = self.capitalizingFirst()
    }
}

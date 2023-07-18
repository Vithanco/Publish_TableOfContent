//
//  File.swift
//  
//
//  Created by Klaus Kneupner on 23/04/2023.
//

import Foundation
extension Array {

  var tail: Array {
    return Array(self.dropFirst())
  }

}

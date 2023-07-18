//
//  File.swift
//  
//
//  Created by Klaus Kneupner on 23/04/2023.
//

import Foundation


extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func count(of needle: Character) -> Int {
        return reduce(0) {
            $1 == needle ? $0 + 1 : $0
        }
    }
    
    public func splitAtFirst(delimiter: String) -> (a: String, b: String)? {
        guard let index =  self.range(of: delimiter) else {
            return nil
        }
        let upperIndex = index.upperBound
        let lowerIndex = index.lowerBound
        let firstPart: String = .init(self.prefix(upTo: lowerIndex))
        let lastPart: String = .init(self.suffix(from: upperIndex))
        return (firstPart, lastPart)
    }
    
    public func splitAtLast(delimiter: String) -> (a: String, b: String)? {
        guard let index =  self.range(of: delimiter,options: [.backwards]) else {
            return nil
        }
        let upperIndex = index.upperBound
        let lowerIndex = index.lowerBound
        let firstPart: String = .init(self.prefix(upTo: lowerIndex))
        let lastPart: String = .init(self.suffix(from: upperIndex))
        return (firstPart, lastPart)
    }
    
    func dropAfterLast(string: String)-> String? {
        if let (result,_) = splitAtLast(delimiter: string) {
            return result
        }
        return nil
    }
}

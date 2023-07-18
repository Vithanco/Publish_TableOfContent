//
//  File.swift
//  
//
//  Created by Klaus Kneupner on 22/04/2023.
//

import Foundation
import Publish

infix operator ~< : AdditionPrecedence
extension Path {
    
    public var withoutIndex: String {
        if self.isIndex {
            return String(self.string.dropLast(6))
        }
        return self.string
    }
    
    public var isIndex: Bool {
        return self.string.hasSuffix("index")
    }
    
    public func hasChild(_ childPath: Path) -> Bool{
        if childPath == self {
            return false
        }
        if string == "" {
            return true
        }
        let relPath : String = childPath.string
        return relPath.contains(self.withoutIndex)
    }
    
    public func hasAncestor(_ parentPath: Path) -> Bool {
        return parentPath.hasChild(self)
    }
    
    public func childDegree(childPath: Path) -> Int{
        if !hasChild(childPath) {
            return -1
        }
        let remainder = childPath.withoutIndex.deletingPrefix(self.withoutIndex)
        return remainder.count(of: "/")
    }
    
    public var parentPath :Path? {
        if let result = self.withoutIndex.dropAfterLast(string: "/") {
            return Path(result)
        }
        return nil
    }
    
    public static func ~< (lhs: Path, rhs: Path) -> Bool {
        
        func compare<S: StringProtocol> (_ lhs: [S],_ rhs:[S]) -> Bool {
            if lhs.count == 0  {
                return true
            }
            if rhs.count == 0 {
                return false
            }
            if lhs[0] == rhs[0] {
                return compare (lhs.tail, rhs.tail)
            }
             return lhs[0] < rhs[0]
        }
        
        let a = lhs.withoutIndex.split(separator: "/")
        let b = rhs.withoutIndex.split(separator: "/")
        
        return compare (a, b)
        
    }
    
    public static func ~> (lhs: Path, rhs: Path) -> Bool {
        
        return !(lhs ~< rhs)
        
    }
    
}


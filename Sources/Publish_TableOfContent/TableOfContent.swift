//
//  File.swift
//
//
//  Created by Klaus Kneupner on 22/04/2023.
//

import Foundation
import Publish
import Plot


public protocol HasShortTitle {
    var shortTitle: String?  {get set}
}

public protocol HasDate {
    var date: Date?  {get set}
}


public protocol TableOfContentEntry : Equatable {
    var title: String { get }
    var path: Path { get }
    var shortTitle: String {get}
    var date: Date? {get}
}

public extension TableOfContentEntry {
    var rPath: Path {
        return Path(path.withoutIndex)
    }
    
    static func == (lhs: any TableOfContentEntry, rhs: any TableOfContentEntry) -> Bool {
        return lhs.path == rhs.path && lhs.title == rhs.title
    }
}

extension Item: TableOfContentEntry  where Site.ItemMetadata : HasShortTitle & HasDate{
    public var date: Date? {
        return self.metadata.date
    }
    
    public var shortTitle: String {
        let result = self.metadata.shortTitle ?? self.title
        if result == "" {
            return title
        }
        return result
    }
}

extension Page: TableOfContentEntry {
    public var shortTitle: String {
        return title
    }
    public var date: Date? {
        return nil
    }
}

extension Section: TableOfContentEntry {
    public var date: Date? {
        return nil
    }
    
    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.path == rhs.path && lhs.title == rhs.title
    }
    
    public var shortTitle: String {
        return title
    }
}

extension Index: TableOfContentEntry {
    public var date: Date? {
        return nil
    }
    
    public static func == (lhs: Index, rhs: Index) -> Bool {
        return lhs.path == rhs.path && lhs.title == rhs.title
    }
    
    
    public var shortTitle: String {
        return title
    }
}


extension Path {
    var isEmpty: Bool {
        return string.isEmpty
    }
}

class TOCData : Equatable {
    let item: any TableOfContentEntry
    var children: [TOCData]
    var fileMode: HTMLFileMode
    
    init(item: any TableOfContentEntry, fileMode: HTMLFileMode) {
        self.item = item
        self.fileMode = fileMode
        children = []
    }
    
    var path: Path {
        return Path(item.path.withoutIndex)
    }
    
    var size : Int {
        return 1 + children.reduce(0,{$0 + $1.size})
    }
    
    func getParent(_ item: any TableOfContentEntry) -> TOCData? {
        guard let parentPath = item.rPath.parentPath else {
            return nil
        }
        if parentPath == self.path {
            return self
        }
        if !self.path.hasChild(parentPath) {
            return nil
        }
        for c in children {
            if let result = c.getParent(item) {
                return result
            }
        }
        return nil
    }
    
    @discardableResult func addChild(_ item: any TableOfContentEntry) -> TOCData {
        let result = TOCData(item: item, fileMode: self.fileMode)
        if let parent = getParent(item) {
            parent.children.append(result)
        } else {
            self.children.append(result)
        }
        return result
    }
    
    var childrenAsHTML: Node<HTML.BodyContext> {
        return .if(children.count > 0,.ul(.forEach(children){
            let link = self.fileMode.filePath(path:$0.item.path)
          //  debugPrint("toc: \($0.item.path) -> \(link)")
            return .li( .a(.href(link), .p(.text($0.item.shortTitle))),$0.childrenAsHTML)
        }))
    }
    
    static func == (lhs: TOCData, rhs: TOCData) -> Bool {
        return lhs.path == rhs.path
    }
    
}

public typealias TableOfContentSorter = (any TableOfContentEntry, any TableOfContentEntry) -> Bool

public enum TableOfContentSortingOrder {
    case title
    case date
    
    var sorting : TableOfContentSorter {
        switch self {
            case .title : return {return $0.path ~< $1.path}
            case .date : return {
                if let a = $0.date {
                    if let b = $1.date {
                        return a > b
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
        }
    }
}

public struct TableOfContent: Component {
    // var items: [TableOfContentEntry]
    var originalPath: Path
    var toc: TOCData
    var fileMode: HTMLFileMode
    
    
    public var body: Component {
        //fputs("    create ToC with \(toc.size) items, starting from: \(toc.item.title) \n",stdout)
        return toc.size > 1 ? Div{
            Paragraph("Table of Contents").class("aside-title")
            self.toc.childrenAsHTML }.class("toc-list") as Component : EmptyComponent() as Component
    }
    
    public init(items: [any TableOfContentEntry], item: any TableOfContentEntry, fileMode: HTMLFileMode = .foldersAndIndexFiles, sortedBy: TableOfContentSortingOrder){
        self.originalPath = item.path
        self.fileMode = fileMode
        let filteredItems = items.filter({return item.path.hasChild($0.path)})
            .sorted(by: sortedBy.sorting)
        
        self.toc = TOCData(item: item, fileMode: fileMode)
        for item in filteredItems {
            toc.addChild(item)
        }
        //    debugPrint("size: \(toc.size)")
    }
}



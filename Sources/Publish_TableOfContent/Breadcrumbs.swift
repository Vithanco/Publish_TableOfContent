//
//  Breadcrumbs.swift
//  
//
//  Created by Klaus Kneupner on 19/07/2023.
//

import Foundation
import Publish
import Plot


public struct Breadcrumbs<Site: Website>: Component where Site.ItemMetadata : HasShortTitle {
    var originalPath: Path
    var _body: ComponentGroup
    
    public var body: Component {
        //  debugPrint("breadcrumb for \(self.originalPath) : \(items.count)")
        return _body.members.count > 0 ? Div {
            _body
        }.class("breadcrumbs") as Component
        : EmptyComponent() as Component
    }
    
    public init(section: Section<Site>, item: any TableOfContentEntry)  {
        self.originalPath = item.path
        var converted = section.items
            .filter({return item.path.hasAncestor($0.path)})
            .sorted(by: {return $0.path ~< $1.path})
            .map({Link($0.title, url: $0.path.absoluteString).class("breadcrumb")})
        for i in stride (from: converted.count-1, through: 1, by: -1) {
            converted.insert(Image(url: "/images/toc/chevron.svg", description: "breadcrumb separator"), at: i)
        }
        _body = ComponentGroup(members: converted)
    }
}

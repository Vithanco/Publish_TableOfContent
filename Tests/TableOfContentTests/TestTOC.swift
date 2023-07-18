//
//  TestTOC.swift
//  
//
//  Created by Klaus Kneupner on 26/04/2023.
//

import XCTest
import Publish
@testable import Publish_TableOfContent

extension TOCData {
    var allChildren: [any TableOfContentEntry] {
        var result = [any TableOfContentEntry]()
        for child in children {
            result.append(child.item)
            result.append(contentsOf: child.allChildren)
        }
        return result
    }
}

final class TestTOC: XCTestCase {
    
    private struct TestData : TableOfContentEntry{
        var title: String
        var path: Path
        var shortTitle: String
        init (_ name: String, _ path:String) {
            self.title = name
            self.shortTitle = name
            self.path = Path(path)
        }
        
        var description: String {
            return title
        }
        
        var debugDescription: String {
            return title
        }
    }


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let parent = TestData("notations","notations")
        let me = TestData ("notations/me","notations/me")
        let child = TestData ("notations/me/child","notations/me/child")
        
        var root = TOCData(item: parent)
        XCTAssertEqual(root.size, 1)
        root.addChild(me)
        XCTAssertEqual(root.size, 2)
        root.addChild(child)
        XCTAssertEqual(root.size, 3)
        let query = root.getParent(child)
        XCTAssertEqual(query?.path, me.path)
        XCTAssertEqual(query?.size,2)
    }

    func testRelations() throws {
        let parent = TestData("parent","parent/index")
        let me = TestData("me","parent/me/index")
        let sibling = TestData("sibling","parent/sibling")
        let child = TestData("child","parent/me/child/index")
        let grandchild = TestData("grandchild","parent/me/child/grandchild")
        
        let parentData = TOCData (item: parent)
        let meData = parentData.addChild(me)
        let siblingData = parentData.addChild(sibling)
        let childData = parentData.addChild(child)
        let grandchildData = parentData.addChild(grandchild)
        
        
        
        XCTAssertEqual(parentData.getParent(me)?.path , parentData.path)
        XCTAssertNil(parentData.getParent(parent))
        XCTAssertNil(meData.getParent(sibling))
        XCTAssertNil(childData.getParent(me))
        XCTAssertNil(childData.getParent(parent))
        XCTAssertEqual(parentData.getParent(grandchild) , childData)
        XCTAssertNil(siblingData.getParent(child))
        
        let children : [TestData] = [sibling,grandchild,child,me]
        let childrenSorted = children.sorted(by: {return $0.path ~< $1.path})
        
        let result : [TestData] = [me,child,grandchild,sibling]
        XCTAssertEqual(result, childrenSorted)
        
       
    }
    
    
    func testRelations2() throws {
        let parent = TestData("parent","parent/index")
        let me = TestData("me","parent/me/index")
        let sibling = TestData("sibling","parent/sibling")
        let sibling2 = TestData("sibling","parent/sibling2")
        let child = TestData("child","parent/me/child/index")
        let grandchild = TestData("grandchild","parent/me/child/grandchild")
        let unrelated = TestData("unrelated","unrelated")
//        let deep = TestData("deep", "parent/me/child2/grandchild2/grandgrandChild")
        
        let children : [TestData] = [sibling,grandchild,child,sibling2,me,parent]
        let childrenSorted = children.sorted(by: {return $0.path ~< $1.path})
        
        let result : [TestData] = [parent,me,child,grandchild,sibling,sibling2]
        XCTAssertEqual(result, childrenSorted)
        
        let notOnlyChildren = [sibling,grandchild,child, unrelated,sibling2,me,parent]
        
        let tocResult = TableOfContent(items: notOnlyChildren, item: parent).toc.allChildren
        let tocTester = [me,child,grandchild,sibling,sibling2]
        XCTAssertEqual(tocResult.map{$0.path},tocTester.map{$0.path})
        
//        let deepTest = [parent,me, deep]
//        let deepResult = [parent,me,deep]
    }
}

//
//  TagParserTests.swift
//  ID3Edit
//
//  Created by Philip Hardy on 6/12/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import XCTest
@testable import ID3Edit

class TagParserTests: XCTestCase {
    
    var parser: TagParser?

    override func setUp() {
        super.setUp()
        
        parser = TagParser(data: NSData(contentsOfFile: "/Users/Phil/Desktop/What A Year.mp3"), tag: ID3Tag())
        parser?.analyzeData()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_getTagSize() {
        XCTAssert(parser?.getTagSize() == 0x110CC)
    }
    
    func test_isTagPresent() {
        XCTAssert(parser!.isTagPresent() == (true, true))
    }
}

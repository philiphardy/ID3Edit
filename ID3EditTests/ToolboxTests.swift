//
//  ToolboxTests.swift
//  ID3Edit
//
//  Created by Philip Hardy on 6/12/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import XCTest
@testable import ID3Edit

typealias Byte = UInt8

class ToolboxTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_toByteArray() {
        var size = Int64(0x1122334455667788)
        var array: [Byte]
        
        // Test 64 bit integer
        array = Toolbox.toByteArray(&size)
        XCTAssert(array.count == 8)
        XCTAssert(array[0] == 0x11)
        XCTAssert(array[1] == 0x22)
        XCTAssert(array[2] == 0x33)
        XCTAssert(array[3] == 0x44)
        XCTAssert(array[4] == 0x55)
        XCTAssert(array[5] == 0x66)
        XCTAssert(array[6] == 0x77)
        XCTAssert(array[7] == 0x88)
        
        // Test 32 bit integer
        var size2 = UInt32(0xFFFFFFFF)
        array = Toolbox.toByteArray(&size2)
        XCTAssert(array.count == 4)
        XCTAssert(array[0] == 0xFF)
        XCTAssert(array[1] == 0xFF)
        XCTAssert(array[2] == 0xFF)
        XCTAssert(array[3] == 0xFF)
    }
}

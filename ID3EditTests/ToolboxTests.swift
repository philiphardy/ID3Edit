//
//  ToolboxTests.swift
//  ID3Edit
//
//    MIT License
//
//    Copyright (c) 2016 Philip Hardy
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import XCTest;
@testable import ID3Edit;

typealias Byte = UInt8;

class ToolboxTests: XCTestCase
{
    func test_toByteArray()
    {
        var size = Int64(0x1122334455667788);
        var array: [Byte];
        
        // Test 64 bit integer
        array = Toolbox.toByteArray(num: &size);
        XCTAssert(array.count == 8);
        XCTAssert(array[0] == 0x11);
        XCTAssert(array[1] == 0x22);
        XCTAssert(array[2] == 0x33);
        XCTAssert(array[3] == 0x44);
        XCTAssert(array[4] == 0x55);
        XCTAssert(array[5] == 0x66);
        XCTAssert(array[6] == 0x77);
        XCTAssert(array[7] == 0x88);
        
        // Test 32 bit integer
        var size2 = UInt32(0x11223344);
        array = Toolbox.toByteArray(num: &size2);
        XCTAssert(array.count == 4);
        XCTAssert(array[0] == 0x11);
        XCTAssert(array[1] == 0x22);
        XCTAssert(array[2] == 0x33);
        XCTAssert(array[3] == 0x44);
    }
    
    func test_removePadding()
    {
        XCTAssertEqual("Tupac", Toolbox.removePadding(str: "\0Tupac\0"));
        XCTAssertEqual("Big Sean", Toolbox.removePadding(str: "\0\0\0Big Sean\0\0\0"));
    }
}

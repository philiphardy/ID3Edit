//
//  TagParserTests.swift
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

class TagParserTests: XCTestCase
{
    private var tagParser: TagParser!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "example", ofType: "mp3")!
        tagParser = TagParser(data: NSData(contentsOfFile: path), tag: ID3Tag());
    }

    func test_getTagSize()
    {
        XCTAssertEqual(tagParser.getTagSize(), 0xA503);
    }
    
    func test_isTagPresent()
    {
        XCTAssert(tagParser.isTagPresent());
    }
}

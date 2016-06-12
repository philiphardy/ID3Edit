//
//  ID3EditTests.swift
//  ID3EditTests
//
//  Created by Philip Hardy on 6/12/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import XCTest
import ID3Edit

class ID3EditTests: XCTestCase
{
    
    var mp3File: MP3File?
    
    override func setUp()
    {
        super.setUp()
        
        do
        {
            mp3File = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3")
        }
        catch let e
        {
            print(e)
        }
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testExample()
    {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

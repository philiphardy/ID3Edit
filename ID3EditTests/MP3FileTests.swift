//
//  MP3FileTests.swift
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
import ID3Edit;

class MP3FileTests: XCTestCase
{

    override func setUp()
    {
        super.setUp();
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown();
    }
    
    func test_init()
    {
        var noErrorsOccurred = true;
        do
        {
            try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3");
            try MP3File(path: "/Users/Phil/Desktop/05 Changes.mp3", overwrite: true);
            
            try MP3File(data: NSData(contentsOfFile: "/Users/Phil/Desktop/What A Year.mp3"));
            try MP3File(data: NSData(contentsOfFile: "/Users/Phil/Desktop/05 Changes.mp3"), overwrite: true);
        }
        catch
        {
            noErrorsOccurred = false;
        }
        
        XCTAssertTrue(noErrorsOccurred);
        
        do
        {
            try MP3File(path: "/Users/Phil/Desktop/What A Year.mp");
        }
        catch
        {
            noErrorsOccurred = false;
        }
        
        XCTAssertTrue(!noErrorsOccurred);
    }
    
    func test_getArtwork()
    {
        do
        {
            let whatAYear = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3");
            let changes = try MP3File(path: "/Users/Phil/Desktop/05 Changes.mp3");
            let soHigh = try MP3File(path: "/Users/Phil/Desktop/1-09 So High.mp3");
            
            whatAYear.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/Big Sean.jpg", atomically: true);
            changes.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/Tupac.jpg", atomically: true);
            soHigh.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/Rebelution.jpg", atomically: true);
        }
        catch {}
    }
    
    func test_writeFile()
    {
        do
        {
            let whatAYear = try MP3File(path: "/Users/Phil/Desktop/BUV2tVduflPh.128.mp3");
            
            whatAYear.setTitle("Tired of talking (A-Trak & Cory Enemy Remix)");
            whatAYear.setArtist("LEON");
            whatAYear.setAlbum("Tired of Talking");
            whatAYear.setLyrics("");
            whatAYear.setArtwork(NSImage(byReferencingFile: "/Users/Phil/Desktop/artwork.png")!, isPNG: true);
            whatAYear.setPath("/Users/Phil/Desktop/\(whatAYear.getArtist()) - \(whatAYear.getTitle()) - \(whatAYear.getAlbum()).mp3")
            try whatAYear.writeTag();
        }
        catch {}
    }
    
    func test_getLyrics()
    {
        do
        {
            let whatAYear = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3");
            let changes = try MP3File(path: "/Users/Phil/Desktop/05 Changes.mp3");
            
            print(whatAYear.getLyrics());
            XCTAssertEqual(changes.getLyrics(), "THIS IS A TEST");
        }
        catch {}
    }

    func test_getAlbum()
    {
        do
        {
            let whatAYear = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3");
            let changes = try MP3File(path: "/Users/Phil/Desktop/05 Changes.mp3");
            XCTAssertEqual(whatAYear.getAlbum(), "What A Year");
            XCTAssertEqual(changes.getAlbum(), "");
        }
        catch {}
    }
    
    func test_getArtist()
    {
        do
        {
            let whatAYear = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3");
            let changes = try MP3File(path: "/Users/Phil/Desktop/05 Changes.mp3");
            XCTAssertEqual(whatAYear.getArtist(), "Big Sean");
            XCTAssertEqual(changes.getArtist(), "Tupac");
        }
        catch {}
    }
}

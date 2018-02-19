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
    func pathFor(name: String, fileType: String) -> String
    {
        let bundle = Bundle(for: type(of: self));
        let path = bundle.path(forResource: name, ofType: fileType)!;
        return path;
    }
    
    func test_init()
    {
        XCTAssertNoThrow(try MP3File(path: pathFor(name: "example", fileType: "mp3")))
        XCTAssertNoThrow(try MP3File(data: NSData(contentsOfFile: pathFor(name: "example", fileType: "mp3")), overwrite: true))
        XCTAssertThrowsError(try MP3File(path: "::a wrong path::"))
    }
    
    func test_getArtwork()
    {
        let artwork = try! MP3File(path: pathFor(name: "example", fileType: "mp3")).getArtwork();
        XCTAssertNotNil(artwork)
        XCTAssertTrue(artwork!.pngWrite(to: URL(fileURLWithPath: NSHomeDirectory() + "/cover.jpg")))
    }
    
    func testReadID3v22tag() {
        let mp3 = try! MP3File(path: pathFor(name: "example", fileType: "mp3"))
        XCTAssertEqual(mp3.getTitle(), "example song")
        XCTAssertEqual(mp3.getAlbum(), "example album")
        XCTAssertEqual(mp3.getArtist(), "example artist")
    }
    
    func testWriteID3withJpg() {
        let mp3 = try! MP3File(path: pathFor(name: "example-to-be-modified", fileType: "mp3"));
        mp3.setTitle(title: "A New title");
        mp3.setArtist(artist: "A New Artist");
        mp3.setAlbum(album: "A New Album");
        //mp3.setLyrics(lyrics: "A New Lyrics");
        mp3.setArtwork(artwork: NSImage(byReferencingFile: pathFor(name: "example-cover", fileType: "jpg"))!, isPNG: false);
        mp3.setPath(path: NSHomeDirectory() + "/mp3-modified-v3-jpg.mp3")
        XCTAssertNoThrow(try mp3.writeTag());
    }
    
    func testWriteid3withPng() {
        let mp3 = try! MP3File(path: pathFor(name: "example-to-be-modified", fileType: "mp3"));
        mp3.setTitle(title: "A New title");
        mp3.setArtist(artist: "A New Artist");
        mp3.setAlbum(album: "A New Album");
        //mp3.setLyrics(lyrics: "A New Lyrics");
        mp3.setArtwork(artwork: NSImage(byReferencingFile: pathFor(name: "example-cover-png", fileType: "png"))!, isPNG: true);
        mp3.setPath(path: NSHomeDirectory() + "/mp3-modified-v3-png.mp3")
        XCTAssertNoThrow(try mp3.writeTag());
    }
    
    func test_getLyrics()
    {
        let mp3 = try! MP3File(path: pathFor(name: "example", fileType: "mp3"));
        XCTAssertEqual(mp3.getLyrics(), "example lyrics");
    }

    func test_getAlbum()
    {
        let mp3 = try! MP3File(path: pathFor(name: "example", fileType: "mp3"));
        XCTAssertEqual(mp3.getAlbum(), "example album");
    }
    
    func test_getArtist()
    {
        let mp3 = try! MP3File(path: pathFor(name: "example", fileType: "mp3"));
        XCTAssertEqual(mp3.getArtist(), "example artist");
    }
}


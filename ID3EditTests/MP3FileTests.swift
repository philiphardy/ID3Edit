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
    func pathFor(mp3: String) -> String
    {
        let bundle = Bundle(for: type(of: self));
        let path = bundle.path(forResource: mp3, ofType: "mp3")!;
        return path;
    }
    
    func test_init()
    {
        XCTAssertNoThrow(try MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus")))
        XCTAssertNoThrow(try MP3File(data: NSData(contentsOfFile: pathFor(mp3: "Jinjer-APlusOrAMinus")), overwrite: true))
        XCTAssertThrowsError(try MP3File(path: "::a wrong path::"))
    }
    
    func test_getArtwork()
    {
        let path = URL(fileURLWithPath: NSHomeDirectory() + "/cover.jpg")
        let mp3 = try! MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus"));
        let artwork = mp3.getArtwork();
        XCTAssertNotNil(artwork)
        XCTAssertTrue(artwork!.pngWrite(to: path))
    }
    
    func test_writeFile()
    {
        let mp3 = try! MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus-ToBeModified"));
        mp3.setTitle(title: "A New title");
        mp3.setArtist(artist: "A New Artist");
        mp3.setAlbum(album: "A New Album");
        mp3.setLyrics(lyrics: "A New Lyrics");
        mp3.setPath(path: NSHomeDirectory() + "/anMp3Modified.mp3")
        XCTAssertNoThrow(try mp3.writeTag());
    }
    
    func test_getLyrics()
    {
        let mp3 = try! MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus"));
        XCTAssertEqual(mp3.getLyrics(), "Lyrics");
    }

    func test_getAlbum()
    {
        let mp3 = try! MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus"));
        XCTAssertEqual(mp3.getAlbum(), "Cloud Factory");
    }
    
    func test_getArtist()
    {
        let mp3 = try! MP3File(path: pathFor(mp3: "Jinjer-APlusOrAMinus"));
        XCTAssertEqual(mp3.getArtist(), "Jinjer");
    }
}


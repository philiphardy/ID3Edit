//
//  ID3Tag.swift
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

import Foundation;

internal class ID3Tag
{
    typealias Byte = UInt8;
    var version: Byte?;
    
    // MARK: - Structs
    private struct AlbumArtwork
    {
        var art: NSData?;
        var isPNG: Bool?;
    }
    
    internal class FRAMES
    {
        internal class V2
        {
            // ID3 version 2 frames
            internal static let FRAME_OFFSET = 6;
            internal static let ARTIST: [Byte] = [0x54, 0x50, 0x31];
            internal static let TITLE: [Byte] = [0x54, 0x54, 0x32];
            internal static let ALBUM: [Byte] = [0x54, 0x41, 0x4C];
            internal static let LYRICS: [Byte] = [0x55, 0x4C, 0x54];
            internal static let ARTWORK: [Byte] = [0x50, 0x49, 0x43];
            internal static let HEADER: [Byte] = [0x49, 0x44, 0x33, 0x02, 0x00, 0x00];
        }
        internal class V3
        {
            // ID3 version 3 frames
            internal static let FRAME_OFFSET = 10;
            internal static let ARTIST: [Byte] = [0x54, 0x50, 0x45, 0x31];
            internal static let TITLE: [Byte] = [0x54, 0x49, 0x54, 0x32];
            internal static let ALBUM: [Byte] = [0x54, 0x41, 0x4C, 0x42];
            internal static let LYRICS: [Byte] = [0x55, 0x53, 0x4C, 0x54];
            internal static let ARTWORK: [Byte] = [0x41, 0x50, 0x49, 0x43];
            internal static let HEADER: [Byte] = [0x49, 0x44, 0x33, 0x03, 0x00, 0x00];
        }
    }
    
    // MARK: - Constants
    internal static let TAG_OFFSET = 10;
    internal static let ART_FRAME_OFFSET = 12;
    internal static let LYRICS_FRAME_OFFSET = 11;
    internal static let VERSION_OFFSET = 3;
    
    // MARK: - Instance Variables
    private var artist = "";
    private var title = "";
    private var album = "";
    private var lyrics = "";
    private var artwork = AlbumArtwork();
    
    
    // MARK: - Accessor Methods
    internal func getArtwork() -> NSImage?
    {
        if artwork.art != nil
        {
            let image = NSImage(data: artwork.art! as Data);
            return image;
        }
        
        return nil
    }
    
    internal func getArtist() -> String
    {
        return artist;
    }
    
    internal func getTitle() -> String
    {
        return title;
    }
    
    internal func getAlbum() -> String
    {
        return album;
    }
    
    internal func getLyrics() -> String
    {
        return lyrics;
    }
    
    // MARK: - Mutator Methods
    
    internal func setArtist(artist: String)
    {
        self.artist = Toolbox.removePadding(str: artist);
    }
    
    internal func setTitle(title: String)
    {
        self.title = Toolbox.removePadding(str: title);
    }
    
    internal func setAlbum(album: String)
    {
        self.album = Toolbox.removePadding(str: album);
    }
    
    internal func setLyrics(lyrics: String)
    {
        self.lyrics = Toolbox.removePadding(str: lyrics);
    }
    
    internal func setArtwork(artwork: NSImage, isPNG: Bool)
    {
        let imgRep = NSBitmapImageRep(data: artwork.tiffRepresentation!);
        
        if isPNG
        {
            self.artwork.art = imgRep?.representation(using: .png , properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 0.5])! as NSData?;
        }
        else
        {
            self.artwork.art = imgRep?.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 0.5]) as NSData?;
        }
        
        self.artwork.isPNG = isPNG;
    }
    
    internal func setArtwork(artwork: NSData, isPNG: Bool)
    {
        self.artwork.art = artwork;
        self.artwork.isPNG = isPNG;
    }
    
    // MARK: - Tag Creation
    internal func getBytes() -> [Byte]
    {
        var content: [Byte] = [];
        
        if infoExists(category: artist)
        {
            // Create the artist frame
            let frame = createFrame(frame: version == 3 ? FRAMES.V3.ARTIST : FRAMES.V2.ARTIST, str: getArtist());
            content.append(contentsOf: frame);
        }
        
        if infoExists(category: title)
        {
            // Create the title frame
            let frame = createFrame(frame: version == 3 ? FRAMES.V3.TITLE : FRAMES.V2.TITLE, str: getTitle());
            content.append(contentsOf: frame);
        }
        
        if infoExists(category: album)
        {
            // Create the album frame
            let frame = createFrame(frame: version == 3 ? FRAMES.V3.ALBUM : FRAMES.V2.ALBUM, str: getAlbum());
            content.append(contentsOf: frame);
        }
        
        if infoExists(category: lyrics)
        {
            // Create the lyrics frame
            let frame = createLyricFrame();
            content.append(contentsOf: frame);
        }
        
        if artwork.art != nil
        {
            // Create the artwork frame
            let frameFront = createArtFrame(type: 0x03);
            content.append(contentsOf: frameFront);
        }
        
        if content.count == 0
        {
            // Prevent writing a tag header
            // if no song info is present
            return content;
        }
        
        // Make the tag header
        var header = createTagHeader(contentSize: content.count);
        header.append(contentsOf: content);
        
        return header;
    }
    
    private func createFrame(frame: [Byte], str: String) -> [Byte] {
        var bytes: [Byte] = frame;
        var cont = [Byte](str.utf8);
        
        if cont[0] != 0 {
            // Add padding to the beginning
            cont.insert(0, at: 0);
        }
        
        if (cont.last != 0) {
            // Add padding to the end
            cont.append(0);
        }
        
        // Add the size to the byte array
        var int = UInt32(cont.count);
        var size = Toolbox.toByteArray(num: &int);
        
        if version != 3 {
            size.removeFirst();
        }
        
        // Create the frame
        bytes.append(contentsOf: size);
        if (version == 3) {
            //Flags (not set)
            bytes.append(0)
            bytes.append(0)
        }
        bytes.append(contentsOf: cont);
        
        // Return the completed frame
        return bytes;
    }
    
    
    private func createLyricFrame() -> [Byte]
    {
        var bytes: [Byte] = FRAMES.V2.LYRICS;
        
        let encoding: [Byte] = [0x00, 0x65, 0x6E, 0x67, 0x00];
        
        let content = [Byte](getLyrics().utf8);
        
        var size = UInt32(content.count + encoding.count);
        var sizeArr = Toolbox.toByteArray(num: &size);
        sizeArr.removeFirst();
        
        // Form the header
        bytes.append(contentsOf: sizeArr);
        bytes.append(contentsOf: encoding);
        bytes.append(contentsOf: content);
        
        return bytes;
    }
    
    
    private func createTagHeader(contentSize: Int) -> [Byte]
    {
        var bytes: [Byte] = version == 3 ? FRAMES.V3.HEADER : FRAMES.V2.HEADER;
        
        // Add the size to the byte array
        var formattedSize = UInt32(format(size: contentSize));

        bytes.append(contentsOf: Toolbox.toByteArray(num: &formattedSize));
        
        // Return the completed tag header
        return bytes;
    }
    
    
    private func createArtFrame(type: Byte) -> [Byte] {
        var bytes: [Byte] = version == 3 ? FRAMES.V3.ARTWORK : FRAMES.V2.ARTWORK;
        // Calculate size
        var size = UInt32(artwork.art!.length + (version == 3 ? (artwork.isPNG! ? 13 : 14) : 6));
        var sizeArr = Toolbox.toByteArray(num: &size);
        
        if (version != 3) {
            sizeArr.removeFirst();
        }
        
        bytes.append(contentsOf: sizeArr);
        
        if (version == 3) {
            //Flags (not set)
            bytes.append(0)
            bytes.append(0)
        }
        
        // Append encoding
        if(artwork.isPNG!) {
            if (version == 3) {
                bytes.append(contentsOf: [0x00, 0x69, 0x6D, 0x61, 0x67, 0x65, 0x2F, 0x70, 0x6E, 0x67, 0x00, type, 0x00]);
            } else {
                bytes.append(contentsOf: [0x00, 0x50, 0x4E, 0x47, type, 0x00]);
            }
        } else {
            if (version == 3) {
                bytes.append(contentsOf: [0x00, 0x69, 0x6D, 0x61, 0x67, 0x65, 0x2F, 0x6A, 0x70, 0x65, 0x67, 0x00, type, 0x00]);
            } else {
                bytes.append(contentsOf: [0x00, 0x4A, 0x50, 0x47, type, 0x00]);
            }
        }
        
        // Add artwork data
        let artworkData = Array(UnsafeBufferPointer(start: artwork.art!.bytes.assumingMemoryBound(to: Byte.self), count: artwork.art!.length))
        bytes.append(contentsOf: artworkData);

        return bytes;
    }
    
    private func format(size: Int) -> Int {
        var out:Int = 0
        var mask:Int = 0x7F
        var currentValue = size
        while (mask != 0x7FFFFFFF) {
            out = currentValue & ~mask;
            out = out << 1;
            out = out | currentValue & mask;
            mask = ((mask + 1) << 8) - 1;
            currentValue = out;
        }
        return out;
    }
    
    private func infoExists(category: String) -> Bool
    {
        return category != "";
    }
}

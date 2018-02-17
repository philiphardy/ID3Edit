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
            let frame = createFrame(frame: FRAMES.V2.ARTIST, str: getArtist());
            content.append(contentsOf: frame);
        }
        
        if infoExists(category: title)
        {
            // Create the title frame
            let frame = createFrame(frame: FRAMES.V2.TITLE, str: getTitle());
            content.append(contentsOf: frame);
        }
        
        if infoExists(category: album)
        {
            // Create the album frame
            let frame = createFrame(frame: FRAMES.V2.ALBUM, str: getAlbum());
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
            let frame = createArtFrame();
            content.append(contentsOf: frame);
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
    
    private func createFrame(frame: [Byte], str: String) -> [Byte]
    {
        var bytes: [Byte] = frame;
        
        var cont = [Byte](str.utf8);
        
        if cont[0] != 0
        {
            // Add padding to the beginning
            cont.insert(0, at: 0);
        }
        
        if cont.last != 0
        {
            // Add padding to the end
            cont.append(0);
        }
        
        // Add the size to the byte array
        var int = UInt32(cont.count);
        var size = Toolbox.toByteArray(num: &int);
        size.removeFirst();
        
        // Create the frame
        bytes.append(contentsOf: size);
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
        var bytes: [Byte] = FRAMES.V2.HEADER;
        
        // Add the size to the byte array
        var formattedSize = UInt32(calcSize(size: contentSize));
        bytes.append(contentsOf: Toolbox.toByteArray(num: &formattedSize));
        
        // Return the completed tag header
        return bytes;
    }
    
    
    private func createArtFrame() -> [Byte]
    {
        var bytes: [Byte] = FRAMES.V2.ARTWORK;
        
        // Calculate size
        var size = UInt32(artwork.art!.length + 6);
        var sizeArr = Toolbox.toByteArray(num: &size);
        sizeArr.removeFirst();
        
        bytes.append(contentsOf: sizeArr);
        
        // Append encoding
        if(artwork.isPNG!)
        {
            bytes.append(contentsOf: [0x00, 0x50, 0x4E, 0x47, 0x00 ,0x00]);
        }
        else
        {
            bytes.append(contentsOf: [0x00, 0x4A, 0x50, 0x47, 0x00 ,0x00]);
        }
        
        // Add artwork data
        let artworkData = Array(UnsafeBufferPointer(start: artwork.art!.bytes.assumingMemoryBound(to: Byte.self), count: artwork.art!.length))
        bytes.append(contentsOf: artworkData);

        return bytes;
    }
    
    
    // MARK: - Helper Methods
    private func calcSize(size: Int) -> Int
    {
        // Holds the size of the tag
        var newSize = 0;
        
        for i in 0 ..< 4
        {
            // Get the bytes from size
            let shift = i * 8;
            let mask = 0xFF << shift;
            
            
            // Shift the byte down in order to use the mask
            var byte = (size & mask) >> shift;
            
            var oMask: Byte = 0x80;
            for _ in 0 ..< i
            {
                // Create the overflow mask
                oMask >>= 1;
                oMask += 0x80;
            }
            
            // The left side of the byte
            let overflow = Byte(byte) & oMask;
            
            // The right side of the byte
            let untouched = Byte(byte) & ~oMask;
            
            // Store the byte
            byte = ((Int(overflow) << 1) + Int(untouched)) << (shift + i);
            newSize += byte;
        }
        
        return newSize;
    }
    
    private func infoExists(category: String) -> Bool
    {
        return category != "";
    }
}

//
//  ID3Tag.swift
//  ID3Edit
//
//  Created by Philip Hardy on 1/10/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import Foundation

internal class ID3Tag
{
    typealias Byte = UInt8
    
    // MARK: - Structs
    private struct AlbumArtwork
    {
        var art: NSData?
        var isPNG: Bool?
    }
    
    internal class FRAMES
    {
        static let ARTIST: [Byte] = [0x54, 0x50, 0x31]
        static let TITLE: [Byte] = [0x54, 0x54, 0x32]
        static let ALBUM: [Byte] = [0x54, 0x41, 0x4C]
        static let LYRICS: [Byte] = [0x55, 0x4C, 0x54]
        static let ARTWORK: [Byte] = [0x50, 0x49, 0x43]
        static let HEADER: [Byte] = [0x49, 0x44, 0x33, 0x02, 0x00, 0x00]
    }
    
    // MARK: - Constants
    internal static let TAG_OFFSET = 10
    internal static let FRAME_OFFSET = 6
    internal static let ART_FRAME_OFFSET = 12
    internal static let LYRICS_FRAME_OFFSET = 11
    
    // MARK: - Instance Variables
    private var artist = ""
    private var title = ""
    private var album = ""
    private var lyrics = ""
    private var artwork = AlbumArtwork()
    
    
    // MARK: - Accessor Methods
    internal func getArtwork() -> NSImage?
    {
        if artwork.art != nil
        {
            return NSImage(data: artwork.art!)
        }
        
        return nil
    }
    
    internal func getArtist() -> String
    {
        return artist
    }
    
    internal func getTitle() -> String
    {
        return title
    }
    
    internal func getAlbum() -> String
    {
        return album
    }
    
    internal func getLyrics() -> String
    {
        return lyrics
    }
    
    // MARK: - Mutator Methods
    
    internal func setArtist(artist: String)
    {
        self.artist = artist
    }
    
    internal func setTitle(title: String)
    {
        self.title = title
    }
    
    internal func setAlbum(album: String)
    {
        self.album = album
    }
    
    internal func setLyrics(lyrics: String)
    {
        self.lyrics = lyrics
    }
    
    internal func setArtwork(artwork: NSImage, isPNG: Bool)
    {
        let imgRep = NSBitmapImageRep(data: artwork.TIFFRepresentation!)
        
        if isPNG
        {
            self.artwork.art = imgRep?.representationUsingType(.NSPNGFileType , properties: [NSImageCompressionFactor: 0.5])
        }
        else
        {
            self.artwork.art = imgRep?.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: 0.5])
        }
        
        
        self.artwork.isPNG = isPNG
    }
    
    internal func setArtwork(artwork: NSData, isPNG: Bool)
    {
        self.artwork.art = artwork
        self.artwork.isPNG = isPNG
    }
    
    // MARK: - Tag Creation
    internal func getBytes() -> [Byte]
    {
        var content: [Byte] = []
        
        if infoExists(artist)
        {
            // Create the artist frame
            let frame = createFrame(FRAMES.ARTIST, str: getArtist())
            content.appendContentsOf(frame)
        }
        
        if infoExists(title)
        {
            // Create the title frame
            let frame = createFrame(FRAMES.TITLE, str: getTitle())
            content.appendContentsOf(frame)
        }
        
        if infoExists(album)
        {
            // Create the album frame
            let frame = createFrame(FRAMES.ALBUM, str: getAlbum())
            content.appendContentsOf(frame)
        }
        
        if infoExists(lyrics)
        {
            // Create the lyrics frame
            let frame = createLyricFrame()
            content.appendContentsOf(frame)
        }
        
        if artwork.art != nil
        {
            // Create the artwork frame
            let frame = createArtFrame()
            content.appendContentsOf(frame)
        }
        
        if content.count == 0
        {
            // Prevent writing a tag header
            // if no song info is present
            return content
        }
        
        // Make the tag header
        var header = createTagHeader(content.count)
        header.appendContentsOf(content)
        
        return header
    }
    
    private func createFrame(frame: [Byte], str: String) -> [Byte]
    {
        var bytes: [Byte] = frame
        
        var cont = [Byte](str.utf8)
        
        if cont[0] != 0
        {
            // Add padding to the beginning
            cont.insert(0, atIndex: 0)
        }
        
        if cont.last != 0
        {
            // Add padding to the end
            cont.append(0)
        }
        
        // Add the size to the byte array
        var size = toByteArray(UInt32(cont.count))
        size.removeFirst()
        
        // Create the frame
        bytes.appendContentsOf(size)
        bytes.appendContentsOf(cont)
        
        // Return the completed frame
        return bytes
    }
    
    
    private func createLyricFrame() -> [Byte]
    {
        var bytes: [Byte] = FRAMES.LYRICS
        
        let encoding: [Byte] = [0x00, 0x65, 0x6E, 0x67, 0x00]
        
        let content = [Byte](getLyrics().utf8)
        
        var size = toByteArray(UInt32(content.count + encoding.count))
        size.removeFirst()
        
        // Form the header
        bytes.appendContentsOf(size)
        bytes.appendContentsOf(encoding)
        bytes.appendContentsOf(content)
        
        return bytes
    }
    
    
    private func createTagHeader(contentSize: Int) -> [Byte]
    {
        var bytes: [Byte] = FRAMES.HEADER
        
        // Add the size to the byte array
        let formattedSize = UInt32(calcSize(contentSize))
        bytes.appendContentsOf(toByteArray(formattedSize))
        
        // Return the completed tag header
        return bytes
    }
    
    
    private func createArtFrame() -> [Byte]
    {
        var bytes: [Byte] = FRAMES.ARTWORK
        
        // Calculate size
        var size = toByteArray(UInt32(artwork.art!.length + 6))
        size.removeFirst()
        
        bytes.appendContentsOf(size)
        
        // Append encoding
        if artwork.isPNG!
        {
            // PNG encoding
            bytes.appendContentsOf([0x00, 0x50, 0x4E, 0x47, 0x00 ,0x00])
        }
        else
        {
            // JPG encoding
            bytes.appendContentsOf([0x00, 0x4A, 0x50, 0x47, 0x00 ,0x00])
        }
        
        // Add artwork data
        bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer<Byte>(artwork.art!.bytes), count: artwork.art!.length)))
        
        return bytes
    }
    
    // MARK: - Helper Methods
    
    
    
    private func calcSize(size: Int) -> Int
    {
        // Holds the size of the tag
        var newSize = 0
        
        for var i = 0; i < 4; i++
        {
            // Get the bytes from size
            let shift = i * 8
            let mask = 0xFF << shift
            
            
            // Shift the byte down in order to use the mask
            var byte = (size & mask) >> shift
            
            var oMask: Byte = 0x80
            for var j = 0; j < i; j++
            {
                // Create the overflow mask
                oMask = oMask >> 1
                oMask += 0x80
            }
            
            // The left side of the byte
            let overflow = Byte(byte) & oMask
            
            // The right side of the byte
            let untouched = Byte(byte) & ~oMask
            
            // Store the byte
            byte = ((Int(overflow) << 1) + Int(untouched)) << (shift + i)
            newSize += byte
        }
        
        return newSize
    }
    
    private func infoExists(category: String) -> Bool
    {
        return category != ""
    }
    
    private func toByteArray<T>(var num: T) -> [Byte]
    {
        // Get pointer to number
        let ptr = withUnsafePointer(&num) {
            UnsafePointer<Byte>($0)
        }
        
        // The array to store the bytes
        var bytes: [Byte] = []
        
        for var i = sizeof(T) - 1; i >= 0; i--
        {
            bytes.append(ptr[i])
        }
        
        return bytes
    }
}
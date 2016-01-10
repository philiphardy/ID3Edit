//
//  MP3File.swift
//  ID3Edit
//
//  Created by Philip Hardy on 1/6/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import Foundation


/**
 Opens an MP3 file for reading and writing the ID3 tag
 
 - Parameter path: The path to the MP3 file
 - Parameter overwrite: Overwrite the ID3 tag in the file if one exists. (Default value is false) 
 
 **Note**: If there is an ID3 tag present but not of version 2.x the ID3 tag will be overwritten when the new tag is written
 
 - Throws: `ID3EditErrors.FileDoesNotExist` if the file at the given path does not exist or `ID3EditErrors.NotAnMP3` if the file is not an MP3
*/
public class MP3File
{
    
    typealias Byte = UInt8
    
    // MARK: - Constants
    private let BYTE = 8
    private let TAG_OFFSET = 10
    private let FRAME_OFFSET = 6
    private let ART_FRAME_OFFSET = 12
    private let LYRICS_FRAME_OFFSET = 11
    private struct FRAMES
    {
        static let ARTIST: [Byte] = [0x54, 0x50, 0x31]
        static let TITLE: [Byte] = [0x54, 0x54, 0x32]
        static let ALBUM: [Byte] = [0x54, 0x41, 0x4C]
        static let LYRICS: [Byte] = [0x55, 0x4C, 0x54]
        static let ARTWORK: [Byte] = [0x50, 0x49, 0x43]
        static let HEADER: [Byte] = [0x49, 0x44, 0x33, 0x02, 0x00, 0x00]
    }
    
    // MARK: - Instance Variables
    private let path: String
    private var data: NSData?
    private var songInfo = ["artist": "", "title": "", "album": "", "lyrics": ""] // Artist, Title, Album, Lyrics
    private var art: NSData?
    private var isPNG: Bool?
    
    
    
    public init(path: String, overwrite: Bool = false) throws
    {
        // Store the url in order to write to it later
        self.path = path
        
        // Check the path extension
        if (path as NSString).pathExtension.caseInsensitiveCompare("mp3") != NSComparisonResult.OrderedSame
        {
            throw ID3EditErrors.NotAnMP3
        }
        
        // Get the data from the url
        data = NSData(contentsOfFile: path)
        
        if data == nil
        {
            throw ID3EditErrors.FileDoesNotExist
        }
        
        // Analyze the data
        if !overwrite
        {
            analyzeData()
        }
    }
    
    
    // MARK: - Accessor Methods
    
    /**
     Returns the artwork for this file
     
     - Returns: An `NSImage` if artwork exists and `nil` otherwise
     */
    public func getArtwork() -> NSImage?
    {
        if art != nil
        {
            return NSImage(data: art!)
        }
        
        return nil
    }
    
    /**
     Returns the artist for the file
     
     - Returns: The song artist or a blank `String` if not available
     */
    public func getArtist() -> String
    {
        return songInfo["artist"]!
    }
    
    
    /**
     Returns the title of the song
     
     - Returns: The song title or a blank `String` if not available
     */
    public func getTitle() -> String
    {
        return songInfo["title"]!
    }
    
    
    /**
     Returns the album of the song
     
     - Returns: The song album or a blank `String` if not available
    */
    public func getAlbum() -> String
    {
        return songInfo["album"]!
    }
    
    
    /**
     Returns the lyrics of the song
     
     - Returns: The lyrics of song or a blank `String` if not available
     */
    public func getLyrics() -> String
    {
        return songInfo["lyrics"]!
    }
    
    
    // MARK: - Mutator Methods
    
    
    /**
     Sets the artist for the ID3 tag
     
     - Parameter artist: The artist to be used when the tag is written
     */
    public func setArtist(artist: String)
    {
        songInfo["artist"] = artist
    }
    
    
    /**
     Sets the title for the ID3 tag
     
     - Parameter title: The title to be used when the tag is written
     */
    public func setTitle(title: String)
    {
        songInfo["title"] = title
    }
    
    
    /**
     Sets the album for the ID3 tag
     
     - Parameter album: The album to be used when the tag is written
     */
    public func setAlbum(album: String)
    {
        songInfo["album"] = album
    }
    
    
    /**
     Sets the lyrics for the ID3 tag
     
     - Parameter lyrics: The lyrics to be used when the tag is written
     */
    public func setLyrics(lyrics: String)
    {
        songInfo["lyrics"] = lyrics
    }
    
    
    /**
     Sets the artwork for the ID3 tag
     
     - Parameter artwork: The art to be used when the tag is written
     - Parameter isPNG: Whether the art is in PNG format or JPG
     
     - Note: The artwork can only be PNG or JPG
     */
    public func setArtwork(artwork: NSImage, isPNG: Bool)
    {
        let imgRep = NSBitmapImageRep(data: artwork.TIFFRepresentation!)
        
        if isPNG
        {
            art = imgRep?.representationUsingType(.NSPNGFileType , properties: [NSImageCompressionFactor: 0.5])
        }
        else
        {
            art = imgRep?.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: 0.5])
        }
        
        
        self.isPNG = isPNG
    }
    
    
    // MARK: - Tag Creation Methods
    
    /**
     Writes the new tag to the file
     
     - Returns: `true` if writes successfully, `false` otherwise
     - Throws: Throws `ID3EditErrors.TagSizeOverflow` if tag size is over 256MB
     */
    public func writeTag() throws -> Bool
    {
        // Make the frames
        
        var content: [Byte] = []
        
        if infoExists("artist")
        {
            // Create the artist frame
            let frame = createFrame(FRAMES.ARTIST, str: getArtist())
            content.appendContentsOf(frame)
        }
        
        if infoExists("title")
        {
            // Create the title frame
            let frame = createFrame(FRAMES.TITLE, str: getTitle())
            content.appendContentsOf(frame)
        }
        
        if infoExists("album")
        {
            // Create the album frame
            let frame = createFrame(FRAMES.ALBUM, str: getAlbum())
            content.appendContentsOf(frame)
        }
        
        if infoExists("lyrics")
        {
            // Create the lyrics frame
            let frame = createLyricFrame()
            content.appendContentsOf(frame)
        }
        
        if art != nil
        {
            // Create the artwork frame
            let frame = createArtFrame()
            content.appendContentsOf(frame)
        }
        
        if content.count == 0
        {
            // Prevent writing if there is no data
            return false
        }
        else if content.count > 0xFFFFFFF
        {
            throw ID3EditErrors.TagSizeOverflow
        }
        
        // Make the tag header
        let header = createTagHeader(content.count)
        
        // Form the binary data
        let newData = NSMutableData(bytes: header, length: header.count)
        newData.appendBytes(content, length: content.count)
        
        var tagSize: Int
        
        if isTagPresent().present
        {
            tagSize = getTagSize() + TAG_OFFSET
        }
        else
        {
            tagSize = 0
        }
        
        let music = data!.bytes + tagSize
        newData.appendBytes(music, length: data!.length - tagSize)
        
        // Write the tag to the file
        if newData.writeToFile(path, atomically: true)
        {
            return true
        }
        else
        {
            return false
        }
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
        var size = toByteArray(UInt32(art!.length + 6))
        size.removeFirst()
        
        bytes.appendContentsOf(size)
        
        // Append encoding
        if isPNG!
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
        bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer<Byte>(art!.bytes), count: art!.length)))
        
        return bytes
    }
    
    private func calcSize(size: Int) -> Int
    {
        var bytes: [Int] = []
        
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
            bytes.append(byte)
        }
        
        let result = bytes[0] + bytes[1] + bytes[2] + bytes[3]
        
        return result
    }
    
    
    // MARK: - Tag Analysis
    
    private func analyzeData()
    {
        let tagPresent = isTagPresent()
        if tagPresent.present && tagPresent.version
        {
            // Loop through frames until reach the end of the tag
            extractInfoFromFrames(getTagSize())
        }
    }
    
    
    private func isTagPresent() -> (present: Bool, version: Bool)
    {
        // Determine if a tag is present
        let header = FRAMES.HEADER
        let bytes = UnsafePointer<Byte>(data!.bytes)
        
        var isPresent = true
        
        for var i = 0; i < 3; i++
        {
            isPresent = isPresent && (bytes[i] == header[i])
        }
        
        
        let isCorrectVersion = bytes[3] == header[3]
        
        return (isPresent, isCorrectVersion)
        
    }
    
    
    private func isUseful(frame: [Byte]) -> Bool
    {
        // Determine if the frame is useful
        return isArtistFrame(frame) || isTitleFrame(frame) || isAlbumFrame(frame) || isArtworkFrame(frame) || isLyricsFrame(frame)
    }
    
    
    private func isLyricsFrame(frame: [Byte]) -> Bool
    {
        return frame == FRAMES.LYRICS
    }
    
    
    private func isArtistFrame(frame: [Byte]) -> Bool
    {
        return frame == FRAMES.ARTIST
    }
    
    
    private func isAlbumFrame(frame: [Byte]) -> Bool
    {
        return frame == FRAMES.ALBUM
    }
    
    
    private func isTitleFrame(frame: [Byte]) -> Bool
    {
        return frame == FRAMES.TITLE
    }
    
    
    private func isArtworkFrame(frame: [Byte]) -> Bool
    {
        return frame == FRAMES.ARTWORK
    }

    
    // MARK: - Extraction Methods
    
    private func extractInfoFromFrames(tagSize: Int)
    {
        // Get the tag
        let ptr = UnsafePointer<Byte>(data!.bytes) + TAG_OFFSET
        
        // Loop through all the frames
        var curPosition = 0
        while curPosition < tagSize
        {
            let bytes = ptr + curPosition
            let frameBytes: [Byte] = [bytes[0], bytes[1], bytes[2]]
            let frameSizeBytes: [Byte] = [bytes[3], bytes[4], bytes[5]]
            let frameSize = getFrameSize(frameSizeBytes)
            
            
            // Extract info from current frame if needed
            if isUseful(frameBytes)
            {
                extractInfo(bytes, frameSize: frameSize, frameBytes: frameBytes)
            }
            
            // Check for padding in order to break out
            else if frameBytes[0] == 0 && frameBytes[1] == 0 && frameBytes[2] == 0
            {
                break
            }
            
            // Jump to next frame and move up current position
            curPosition += frameSize
        }
    }
    
    
    private func extractInfo(bytes: UnsafePointer<Byte>, frameSize: Int, frameBytes: [Byte])
    {
        
        if bytes.memory == 0x54 // Starts with 'T' (Artist, Title, or Album)
        {
            // Frame holds text content
            let content = NSString(bytes: bytes + FRAME_OFFSET, length: frameSize - FRAME_OFFSET, encoding: NSASCIIStringEncoding) as! String
            
            if isArtistFrame(frameBytes)
            {
                // Store artist
                setArtist(content)
            }
            else if isTitleFrame(frameBytes)
            {
                // Store title
                setTitle(content)
            }
            else
            {
                // Store album
                setAlbum(content)
            }
        }
        else if bytes.memory == 0x55 // Starts with 'U' (Lyrics)
        {
            // Get lyrics
            let content = NSString(bytes: bytes + LYRICS_FRAME_OFFSET, length: frameSize - LYRICS_FRAME_OFFSET, encoding: NSASCIIStringEncoding) as! String
            
            // Store the lyrics
            setLyrics(content)
        }
        else // Leaves us with artwork
        {
            // Frame holds artwork
            art = NSData(bytes: bytes + ART_FRAME_OFFSET, length: frameSize - ART_FRAME_OFFSET)
            
            // Set art type
            isPNG = bytes[7] != 0x4A // Doesn't equal 'J' for JPG
        }
    }
    
    
    private func getFrameSize(frameSizeBytes: [Byte]) -> Int
    {
        // Calculate the size of the frame
        var size = FRAME_OFFSET
        var shift = 2 * BYTE
        
        for var i = 0; i < 3; i++
        {
            size += Int(frameSizeBytes[i]) << shift
            shift -= BYTE
        }
        
        // Return the frame size including the frame header
        return size
    }
    
    
    private func getTagSize() -> Int
    {
        let ptr = UnsafePointer<Byte>(data!.bytes) + FRAME_OFFSET
        
        var size = 0
        var shift = 21
        
        for var i = 0; i < 4; i++
        {
            size += Int(ptr[i]) << shift
            shift -= 7
        }
        
        return size
    }
    
    
    // MARK: - Helper Methods
    
    private func infoExists(category: String) -> Bool
    {
        return songInfo[category] != ""
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

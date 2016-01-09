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
    
    private let path: String
    private var data: NSData?
    private let lyricsFrameOffset = 11
    private let tagOffset = 10
    private let frameOffset = 6
    private let artFrameOffset = 12
    private var songInfo = ["", "", "", ""] // Artist, Title, Album, Lyrics
    private let padding = 2
    private var art: NSData?
    private var isPNG: Bool?
    private var isCorrectVersion: Bool?
    
    
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
        data = NSMutableData(contentsOfFile: path)
        
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
    
    
    private func analyzeData()
    {
        if isTagPresent() && isCorrectVersion!
        {
            // Loop through frames until reach the end of the tag
            extractInfoFromFrames(getTagSize())
        }
    }
    
    
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
        return getSongInfo(0)
    }
    
    
    /**
     Returns the title of the song
     
     - Returns: The song title or a blank `String` if not available
     */
    public func getTitle() -> String
    {
        return getSongInfo(1)
    }
    
    
    /**
     Returns the album of the song
     
     - Returns: The song album or a blank `String` if not available
    */
    public func getAlbum() -> String
    {
        return getSongInfo(2)
    }
    
    
    /**
     Returns the lyrics of the song
     
     - Returns: The lyrics of song or a blank `String` if not available
     */
    public func getLyrics() -> String
    {
        return getSongInfo(3)
    }
    private func getSongInfo(index: Int) -> String
    {
        return songInfo[index]
    }
    
    
    /**
     Sets the artist for the ID3 tag
     
     - Parameter artist: The artist to be used when the tag is written
     */
    public func setArtist(artist: String)
    {
        setSongInfo(artist, index: 0)
    }
    
    
    /**
     Sets the title for the ID3 tag
     
     - Parameter title: The title to be used when the tag is written
     */
    public func setTitle(title: String)
    {
        setSongInfo(title, index: 1)
    }
    
    
    /**
     Sets the album for the ID3 tag
     
     - Parameter album: The album to be used when the tag is written
     */
    public func setAlbum(album: String)
    {
        setSongInfo(album, index: 2)
    }
    
    
    /**
     Sets the lyrics for the ID3 tag
     
     - Parameter lyrics: The lyrics to be used when the tag is written
     */
    public func setLyrics(lyrics: String)
    {
        setSongInfo(lyrics, index: 3)
    }
    
    
    private func setSongInfo(info: String, index: Int)
    {
        songInfo[index] = info
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
    
    
    private func extractInfoFromFrames(tagSize: Int)
    {
        // Get the tag
        let range = NSRangeFromString("\(tagOffset) \(tagSize)")
        let buffer = UnsafeMutablePointer<Byte>.alloc(tagSize)
        
        // Load the data into the buffer
        data?.getBytes(buffer, range: range)
        
        // Loop through all the frames
        var curPosition = 0
        while curPosition < tagSize
        {
            let frameBytes: [Byte] = [(buffer + curPosition).memory, (buffer + curPosition + 1).memory, (buffer + curPosition + 2).memory]
            let frameSizeBytes: [Byte] = [(buffer + curPosition + 3).memory, (buffer + curPosition + 4).memory, (buffer + curPosition + 5).memory]
            let frameSize = getFrameSize(frameSizeBytes)
            
            
            // Extract info from current frame if needed
            if isUseful(frameBytes)
            {
                extractInfo(buffer, curPos: curPosition, frameSize: frameSize, frameBytes: frameBytes)
            }
            
            // Check for padding in order to break out
            else if frameBytes[0] == 0 && frameBytes[1] == 0 && frameBytes[2] == 0
            {
                break
            }
            
            // Jump to next frame and move up current position
            curPosition += frameSize
        }
        
        // Dealloc the buffer
        buffer.dealloc(tagSize)
    }
    
    
    /**
     Writes the new tag to the file
     
     - Returns: `true` if writes successfully, `false` otherwise
     */
    public func writeTag() -> Bool
    {
        // Make the frames
        
        var content: [Byte] = []
        
        if songInfo[0] != ""
        {
            // Create the artist frame
            content.appendContentsOf(createFrame([84, 80, 49], str: songInfo[0]))
        }
        
        if songInfo[1] != ""
        {
            // Create the title frame
            content.appendContentsOf(createFrame([84, 84, 50], str: songInfo[1]))
        }
        
        if songInfo[2] != ""
        {
            // Create the album frame
            content.appendContentsOf(createFrame([84, 65, 76], str: songInfo[2]))
        }
        
        if songInfo[3] != ""
        {
            // Create the lyrics frame
            content.appendContentsOf(createLyricFrame(songInfo[3]))
        }
        
        if art != nil
        {
            // Create the artwork frame
            content.appendContentsOf(createArtFrame())
        }
        
        if content.count == 0
        {
            // Prevent writing if there is no data
            return false
        }
        
        // Make the tag header
        let header = createTagHeader(content.count)
        
        // Form the binary data
        let newData = NSMutableData(bytes: header, length: header.count)
        newData.appendBytes(content, length: content.count)
        
        var tagSize: Int
        
        if isTagPresent()
        {
            tagSize = getTagSize() + tagOffset
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
    
    
    private func createArtFrame() -> [Byte]
    {
        var bytes: [Byte] = [0x50, 0x49, 0x43]

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
    
    
    private func createLyricFrame(str: String) -> [Byte]
    {
        var bytes: [Byte] = [0x55, 0x4C, 0x54]
        
        let encoding: [Byte] = [0x00, 0x65, 0x6E, 0x67, 0x00]
        
        let content = [Byte](str.utf8)
        
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
        var bytes: [Byte] = [73, 68, 51, 2, 0, 0]
        
        // Add the size to the byte array
        let formattedSize = UInt32(calcSize(contentSize))
        bytes.appendContentsOf(toByteArray(formattedSize))
        
        // Return the completed tag header
        return bytes
    }
    
    
    private func toByteArray<T>(var num: T) -> [Byte]
    {
        let rev = withUnsafePointer(&num) {
            Array(UnsafeBufferPointer(start: UnsafePointer<Byte>($0), count: sizeof(T)))
        }
        
        var cor: [Byte] = []
        for byte in rev
        {
            cor.insert(byte, atIndex: 0)
        }
        
        return cor
    }
    
    
    private func getFrameSize(frameSizeBytes: [Byte]) -> Int
    {
        // Calculate the size of the frame
        let frameSize = Int(frameSizeBytes[0]) << 16 + Int(frameSizeBytes[1]) << 8 + Int(frameSizeBytes[2])
        
        // Return the frame size including the frame header
        return frameSize + frameOffset
    }
    
    
    private func extractInfo(buffer: UnsafeMutablePointer<Byte>, curPos: Int, frameSize: Int, frameBytes: [Byte])
    {
        let curMem = buffer + curPos
        
        if curMem.memory == 84
        {
            // Frame holds text content
            let content = NSString(bytes: curMem + frameOffset, length: frameSize - frameOffset, encoding: NSASCIIStringEncoding) as! String
            
            var i: Int
            if isArtistFrame(frameBytes)
            {
                // Store artist
                i = 0
            }
            else if isTitleFrame(frameBytes)
            {
                // Store title
                i = 1
            }
            else
            {
                // Store album
                i = 2
            }
            
            songInfo[i] = content
        }
        else if curMem.memory == 0x55
        {
            // Get lyrics
            let content = NSString(bytes: curMem + lyricsFrameOffset, length: frameSize - lyricsFrameOffset, encoding: NSASCIIStringEncoding) as! String
            
            // Store the lyrics
            songInfo[3] = content
        }
        else
        {
            // Frame holds artwork
            art = NSData(bytes: curMem + artFrameOffset, length: frameSize - artFrameOffset)
            
            // Set art type
            isPNG = (buffer + 7).memory != 0x4A
        }
    }
    
    
    private func isUseful(frame: [Byte]) -> Bool
    {
        // Determine if the frame is useful
        return isArtistFrame(frame) || isTitleFrame(frame) || isAlbumFrame(frame) || isArtworkFrame(frame) || isLyricsFrame(frame)
    }
    
    
    private func isLyricsFrame(frame: [Byte]) -> Bool
    {
        return frame[0] == 0x55 && frame[1] == 0x4C && frame[2] == 0x54
    }
    
    
    private func isArtistFrame(frame: [Byte]) -> Bool
    {
        return frame[0] == 84 && frame[1] == 80 && frame[2] == 49
    }
    
    
    private func isAlbumFrame(frame: [Byte]) -> Bool
    {
        return frame[0] == 84 && frame[1] == 65 && frame[2] == 76
    }
    
    
    private func isTitleFrame(frame: [Byte]) -> Bool
    {
        return frame[0] == 84 && frame[1] == 84 && frame[2] == 50
    }
    
    
    private func isArtworkFrame(frame: [Byte]) -> Bool
    {
        return frame[0] == 80 && frame[1] == 73 && frame[2] == 67
    }
    
    
    private func getTagSize() -> Int
    {
        let range = NSRangeFromString("6 4")
        let buffer = UnsafeMutablePointer<Byte>.alloc(4)
        
        data?.getBytes(buffer, range: range)
        
        let byte1 = UInt32(buffer.memory) << 21
        
        let byte2 = UInt32((buffer + 1).memory) << 14
        
        let byte3 = UInt32((buffer + 2).memory) << 7
        
        let byte4 = UInt32((buffer + 3).memory)
        
        buffer.dealloc(4)
        
        return Int(byte1 + byte2 + byte3 + byte4)
    }
    
    
    private func isTagPresent() -> Bool
    {
        // Determine if a tag is present
        let len = 4
        let buffer = UnsafeMutablePointer<Byte>.alloc(len)
        
        data?.getBytes(buffer, length: len)
        
        let isPresent = buffer[0] == 73 && buffer[1] == 68 && buffer[2] == 51
        
        isCorrectVersion = buffer[3] == 2
        
        buffer.dealloc(len)
        
        return isPresent
        
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
}

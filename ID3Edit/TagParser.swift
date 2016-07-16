//
//  TagParser.swift
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

import Foundation

internal class TagParser
{
    typealias Byte = UInt8
    
    // MARK: - Constants
    private static let BYTE = 8
    private static let VERSION_OFFSET = 3
    
    // MARK: - Instance Variables
    private static var data: NSData?
    private static var tag: ID3Tag?
    private static var version: Byte?
    private static var frames: AnyClass?
    
    internal static func initialize(data: NSData?, tag: ID3Tag)
    {
        self.data = data
        self.tag = tag
        
        // Make sure there is at least 4 bytes of data
        if data!.length >= 4
        {
            self.version = UnsafePointer<Byte>(data!.bytes)[VERSION_OFFSET]
        }
    }
    
    // MARK: - Tag Analysis
    private static func analyzeData()
    {
        if isTagPresent()
        {
            // Loop through frames until reach the end of the tag
            extractInfoFromFrames(getTagSize())
        }
    }
    
    
    private static func isTagPresent() -> Bool
    {
        // Determine if a tag is present
        let bytes = UnsafePointer<Byte>(data!.bytes)
        
        var isPresent = true
        
        for i in 0 ..< 3
        {
            isPresent = isPresent && (bytes[i] == ID3Tag.FRAMES.V2.HEADER[i] ||
                                      bytes[i] == ID3Tag.FRAMES.V3.HEADER[i])
        }
        
        return isPresent
    }
    
    
    private static func isUseful(frame: [Byte]) -> Bool
    {
        // Determine if the frame is useful
        return isArtistFrame(frame) || isTitleFrame(frame) || isAlbumFrame(frame) || isArtworkFrame(frame) || isLyricsFrame(frame)
    }
    
    
    private static func isLyricsFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.LYRICS
        }
        
        return frame == ID3Tag.FRAMES.V3.LYRICS
    }
    
    
    private static func isArtistFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ARTIST
        }
        
        return frame == ID3Tag.FRAMES.V3.ARTIST
    }
    
    
    private static func isAlbumFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ALBUM
        }
        
        return frame == ID3Tag.FRAMES.V3.ALBUM
    }
    
    
    private static func isTitleFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.TITLE
        }
        
        return frame == ID3Tag.FRAMES.V3.TITLE
    }
    
    
    private static func isArtworkFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ARTWORK
        }
        
        return frame == ID3Tag.FRAMES.V3.ARTWORK
    }
    
    
    // MARK: - Extraction Methods
    private static func extractInfoFromFrames(tagSize: Int)
    {
        // Get the tag
        let ptr = UnsafePointer<Byte>(data!.bytes) + ID3Tag.TAG_OFFSET
        
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
    
    
    private static func extractInfo(bytes: UnsafePointer<Byte>, frameSize: Int, frameBytes: [Byte])
    {
        
        if bytes.memory == 0x54 // Starts with 'T' (Artist, Title, or Album)
        {
            // Frame holds text content
            let content = NSString(bytes: bytes + ID3Tag.FRAME_OFFSET, length: frameSize - ID3Tag.FRAME_OFFSET, encoding: NSASCIIStringEncoding) as! String
            
            if isArtistFrame(frameBytes)
            {
                // Store artist
                tag!.setArtist(content)
            }
            else if isTitleFrame(frameBytes)
            {
                // Store title
                tag!.setTitle(content)
            }
            else
            {
                // Store album
                tag!.setAlbum(content)
            }
        }
        else if bytes.memory == 0x55 // Starts with 'U' (Lyrics)
        {
            // Get lyrics
            let content = NSString(bytes: bytes + ID3Tag.LYRICS_FRAME_OFFSET, length: frameSize - ID3Tag.LYRICS_FRAME_OFFSET, encoding: NSASCIIStringEncoding) as! String
            
            // Store the lyrics
            tag!.setLyrics(content)
        }
        else // Leaves us with artwork
        {
            // Frame holds artwork
            let isPNG = bytes[7] != 0x4A // Doesn't equal 'J' for JPG
            let artData = NSData(bytes: bytes + ID3Tag.ART_FRAME_OFFSET, length: frameSize - ID3Tag.ART_FRAME_OFFSET)
            tag!.setArtwork(artData, isPNG: isPNG)
        }
    }
    
    
    private static func getFrameSize(frameSizeBytes: [Byte]) -> Int
    {
        // Calculate the size of the frame
        var size = ID3Tag.FRAME_OFFSET
        var shift = 2 * BYTE
        
        for i in 0 ..< 3
        {
            size += Int(frameSizeBytes[i]) << shift
            shift -= BYTE
        }
        
        // Return the frame size including the frame header
        return size
    }
    
    
    private static func getTagSize() -> Int
    {
        let ptr = UnsafePointer<Byte>(data!.bytes) + ID3Tag.FRAME_OFFSET
        
        var size = 0
        var shift = 21
        
        for i in 0 ..< 4
        {
            size += Int(ptr[i]) << shift
            shift -= 7
        }
        
        return size
    }
}
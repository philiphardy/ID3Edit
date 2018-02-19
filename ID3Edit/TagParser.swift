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

import CoreFoundation;
import Foundation;

internal class TagParser
{
    typealias Byte = UInt8;
    
    // MARK: - Constants
    private static let BYTE = 8;
    private static let VERSION_OFFSET = 3;
    private static let TAG_SIZE_OFFSET = 6;
    
    // MARK: - Instance Variables
    private var data: NSData?;
    private var tag: ID3Tag?;
    private var version: Byte?;
    
    internal init(data: NSData?, tag: ID3Tag)
    {
        self.data = data;
        self.tag = tag;
        
        // Make sure there is at least 4 bytes of data
        if data!.length >= 4
        {
            version = data?.bytes.assumingMemoryBound(to: Byte.self)[TagParser.VERSION_OFFSET];
            if (version != 2 && version != 3) {
                version  = 3
            }
            tag.version = version
        } else {
            tag.version = 3
        }
    }
    
    // MARK: - Tag Analysis
    internal func analyzeData()
    {
        if isTagPresent()
        {
            // Loop through frames until reach the end of the tag
            extractInfoFromFrames();
        }
    }
    
    
    internal func isTagPresent() -> Bool
    {
        // Determine if a tag is present
        let bytes = data!.bytes.assumingMemoryBound(to: Byte.self);
        var isPresent = false;
        
        for i in 0 ..< 3
        {
            isPresent = isPresent || (bytes[i] == ID3Tag.FRAMES.V2.HEADER[i] || bytes[i] == ID3Tag.FRAMES.V3.HEADER[i]);
        }
        
        return isPresent;
    }
    
    
    private func isUseful(frame: [Byte]) -> Bool
    {
        // Determine if the frame is useful
        return isArtistFrame(frame: frame) ||
            isTitleFrame(frame: frame) ||
            isAlbumFrame(frame: frame) ||
            isArtworkFrame(frame: frame) ||
            isLyricsFrame(frame: frame);
    }
    
    
    private func isLyricsFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.LYRICS;
        }
        
        return frame == ID3Tag.FRAMES.V3.LYRICS;
    }
    
    
    private func isArtistFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ARTIST;
        }
        
        return frame == ID3Tag.FRAMES.V3.ARTIST;
    }
    
    
    private func isAlbumFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ALBUM;
        }
        
        return frame == ID3Tag.FRAMES.V3.ALBUM;
    }
    
    
    private func isTitleFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.TITLE;
        }
        
        return frame == ID3Tag.FRAMES.V3.TITLE;
    }
    
    
    private func isArtworkFrame(frame: [Byte]) -> Bool
    {
        if version == 2
        {
            return frame == ID3Tag.FRAMES.V2.ARTWORK;
        }
        
        return frame == ID3Tag.FRAMES.V3.ARTWORK;
    }
    
    
    // MARK: - Extraction Methods
    private func extractInfoFromFrames()
    {
        let tagSize = getTagSize();
        // Get the tag
        let ptr = data!.bytes.assumingMemoryBound(to: Byte.self) + ID3Tag.TAG_OFFSET;

        // Loop through all the frames
        var curPosition = 0;
        while curPosition < tagSize
        {
            let bytes = ptr + curPosition;
            let frameBytes: [Byte];
            let frameSize: Int;
            
            if version == 2
            {
                frameBytes = [bytes[0], bytes[1], bytes[2]];
                frameSize = getFrameSize(framePtr: bytes, offset: 2);
            }
            else
            {
                frameBytes = [bytes[0], bytes[1], bytes[2], bytes[3]];
                frameSize = getFrameSize(framePtr: bytes, offset: 4);
            }
            
            
            // Extract info from current frame if needed
            if isUseful(frame: frameBytes)
            {
                extractInfo(bytes: bytes, frameSize: frameSize, frameBytes: frameBytes);
            }
                
                // Check for padding in order to break out
            else if frameBytes[0] == 0 && frameBytes[1] == 0 && frameBytes[2] == 0
            {
                break;
            }
            
            // Jump to next frame and move up current position
            curPosition += frameSize;
        }
    }
    
    
    private func extractInfo(bytes: UnsafePointer<Byte>, frameSize: Int, frameBytes: [Byte])
    {
        let frameOffset = getFrameOffset();
        if isArtistFrame(frame: frameBytes)
        {
            // Store artist
            let content = NSString(bytes: bytes + frameOffset, length: frameSize - frameOffset, encoding: String.Encoding.ascii.rawValue)! as String;
            tag!.setArtist(artist: content);
        }
        else if isTitleFrame(frame: frameBytes)
        {
            // Store title
            let content = NSString(bytes: bytes + frameOffset, length: frameSize - frameOffset, encoding: String.Encoding.ascii.rawValue)! as String;
            tag!.setTitle(title: content);
        }
        else if isAlbumFrame(frame: frameBytes)
        {
            // Store album
            let content = NSString(bytes: bytes + frameOffset, length: frameSize - frameOffset, encoding: String.Encoding.ascii.rawValue)! as String;
            tag!.setAlbum(album: content);
        }
        else if isLyricsFrame(frame: frameBytes)
        {
            // Get lyrics
            let LYRICS_OFFSET = frameOffset + 5;
            let content = NSString(bytes: bytes + LYRICS_OFFSET, length: frameSize - LYRICS_OFFSET, encoding: String.Encoding.ascii.rawValue)! as String;
            
            // Store the lyrics
            tag!.setLyrics(lyrics: content);
        }
        else // Artwork
        {
            // Frame holds artwork
            let JPG_ID: [Byte] = [0xFF, 0xD8, 0xFF, 0xE0];
            let PNG_ID: [Byte] = [0x89, 0x50, 0x4E, 0x47];
            
            var isPNG = true;
            var ptr = bytes + frameOffset;
            
            for _ in 0...frameSize
            {
                if (ptr[0] == JPG_ID[0]) && (ptr[1] == JPG_ID[1]) && (ptr[2] == JPG_ID[2]) && (ptr[3] == JPG_ID[3])
                {
                    // JPG binary data found
                    isPNG = false;
                    break;
                }
                else if (ptr[0] == PNG_ID[0]) && (ptr[1] == PNG_ID[1]) && (ptr[2] == PNG_ID[2]) && (ptr[3] == PNG_ID[3])
                {
                    // PNG binary data found
                    break;
                }
                
                // move traversal pointer up
                ptr += 1;
            }
            let artData = NSData(bytes: ptr, length: frameSize - (ptr - bytes));
            tag!.setArtwork(artwork: artData, isPNG: isPNG);
        }
    }
    
    
    private func getFrameSize(framePtr: UnsafePointer<Byte>, offset: Int) -> Int
    {
        // Calculate the size of the frame
        var size = Int(CFSwapInt32HostToBig(UnsafePointer(framePtr + offset).withMemoryRebound(to: UInt32.self, capacity: 1) {
            $0.pointee
        }))

        if(self.version == 2)
        {
            // Extract the first 3 bytes
            size &= 0x00FFFFFF;
        }
        
        // Return the frame size including the frame header
        return size + getFrameOffset();
    }
    
    
    internal func getTagSize() -> Int
    {
        let size = CFSwapInt32HostToBig((data!.bytes + TagParser.TAG_SIZE_OFFSET).assumingMemoryBound(to: UInt32.self).pointee);
        let b1 = (size & 0x7F000000) >> 3;
        let b2 = (size & 0x007F0000) >> 2;
        let b3 = (size & 0x00007F00) >> 1;
        let b4 =  size & 0x0000007F;
        
        return Int(b1 + b2 + b3 + b4);
    }
    
    
    private func getFrameOffset() -> Int
    {
        if(self.version == 2)
        {
            return ID3Tag.FRAMES.V2.FRAME_OFFSET;
        }
        else
        {
            return ID3Tag.FRAMES.V3.FRAME_OFFSET;
        }
    }
}

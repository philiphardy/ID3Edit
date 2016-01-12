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
    
    // MARK: - Instance Variables
    private let parser: TagParser?
    private let tag: ID3Tag = ID3Tag()
    private var path: String?
    private let data: NSData?
    
    
    
    public init(path: String, overwrite: Bool = false) throws
    {
        // Store the url in order to write to it later
        self.path = path
        
        // Get the data from the file
        data = NSData(contentsOfFile: path)
        parser = TagParser(data: data, tag: tag)
        
        if data == nil
        {
            // The file does not exist
            throw ID3EditErrors.FileDoesNotExist
        }
        
        // Check the path extension
        if (path as NSString).pathExtension.caseInsensitiveCompare("mp3") != NSComparisonResult.OrderedSame
        {
            throw ID3EditErrors.NotAnMP3
        }
        
        // Analyze the data
        if !overwrite
        {
            parser!.analyzeData()
        }
    }
    
    
    public init(data: NSData?, overwrite: Bool = false) throws
    {
        
        self.data = data
        parser = TagParser(data: data, tag: tag)
        
        if data == nil
        {
            throw ID3EditErrors.NoDataExists
        }
        
        // Analyze the data
        if !overwrite
        {
            parser!.analyzeData()
        }
    }
    
    
    // MARK: - Accessor Methods
    
    /**
     Returns the artwork for this file
     
     - Returns: An `NSImage` if artwork exists and `nil` otherwise
     */
    public func getArtwork() -> NSImage?
    {
        return tag.getArtwork()
    }
    
    /**
     Returns the artist for the file
     
     - Returns: The song artist or a blank `String` if not available
     */
    public func getArtist() -> String
    {
        return tag.getArtist()
    }
    
    
    /**
     Returns the title of the song
     
     - Returns: The song title or a blank `String` if not available
     */
    public func getTitle() -> String
    {
        return tag.getTitle()
    }
    
    
    /**
     Returns the album of the song
     
     - Returns: The song album or a blank `String` if not available
    */
    public func getAlbum() -> String
    {
        return tag.getAlbum()
    }
    
    
    /**
     Returns the lyrics of the song
     
     - Returns: The lyrics of song or a blank `String` if not available
     */
    public func getLyrics() -> String
    {
        return tag.getLyrics()
    }
    
    
    // MARK: - Mutator Methods
    
    /**
    Sets the path for the mp3 file to be written
    
    - Parameter path: The path of for the file to be written
    */
    public func setPath(path: String)
    {
        self.path = path
    }
    
    
    /**
     Sets the artist for the ID3 tag
     
     - Parameter artist: The artist to be used when the tag is written
     */
    public func setArtist(artist: String)
    {
        tag.setArtist(artist)
    }
    
    
    /**
     Sets the title for the ID3 tag
     
     - Parameter title: The title to be used when the tag is written
     */
    public func setTitle(title: String)
    {
        tag.setTitle(title)
    }
    
    
    /**
     Sets the album for the ID3 tag
     
     - Parameter album: The album to be used when the tag is written
     */
    public func setAlbum(album: String)
    {
        tag.setAlbum(album)
    }
    
    
    /**
     Sets the lyrics for the ID3 tag
     
     - Parameter lyrics: The lyrics to be used when the tag is written
     */
    public func setLyrics(lyrics: String)
    {
        tag.setLyrics(lyrics)
    }
    
    
    /**
     Sets the artwork for the ID3 tag
     
     - Parameter artwork: The art to be used when the tag is written
     - Parameter isPNG: Whether the art is in PNG format or JPG
     
     - Note: The artwork can only be PNG or JPG
     */
    public func setArtwork(artwork: NSImage, isPNG: Bool)
    {
        tag.setArtwork(artwork, isPNG: isPNG)
    }
    
    
    // MARK: - Tag Creation Methods
    
    /**
     Writes the new tag to the file
     
     - Returns: `true` if writes successfully, `false` otherwise
     - Throws: Throws `ID3EditErrors.TagSizeOverflow` if tag size is over 256MB
     */
    public func writeTag() throws -> Bool
    {
        if path == nil
        {
            // No path is set, prevent writing
            throw ID3EditErrors.NoPathSet
        }
        
        do
        {
            let newData = try getMP3Data()
            
            // Write the tag to the file
            if newData.writeToFile(path!, atomically: true)
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch let err
        {
            throw err
        }
    }
    
    /**
     Returns the MP3 file data with the new tag included
     
     - Returns: The MP3 data with the new tag included
     - Note: The data is ready to write to a file
     */
    public func getMP3Data() throws -> NSData
    {
        
        if data == nil
        {
            // Prevent writing if there is no data
            throw ID3EditErrors.NoDataExists
        }
        
        // Get the tag bytes
        let content = tag.getBytes()
        
        if content.count == 0
        {
            return data!
        }
        else if content.count > 0xFFFFFFF
        {
            throw ID3EditErrors.TagSizeOverflow
        }
        
        // Form the binary data
        let newData = NSMutableData(bytes: content, length: content.count)
        
        var tagSize: Int
        
        if parser!.isTagPresent().present
        {
            tagSize = parser!.getTagSize() + ID3Tag.TAG_OFFSET
        }
        else
        {
            tagSize = 0
        }
        
        let music = data!.bytes + tagSize
        newData.appendBytes(music, length: data!.length - tagSize)
        
        return newData
    }
}

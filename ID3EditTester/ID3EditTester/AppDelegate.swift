//
//  AppDelegate.swift
//  ID3EditTester
//
//  Created by Philip Hardy on 1/9/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

import Cocoa
import ID3Edit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Test the framework
        do
        {
            let file = try MP3File(path: "/Users/Phil/Desktop/What A Year.mp3")
            
            // Test information parsing
            print("Title:\t\(file.getTitle())")
            print("Artist:\t\(file.getArtist())")
            print("Album:\t\(file.getAlbum())")
            print("Lyrics:\t\(file.getLyrics())")

            // Save the artwork to the desktop
            file.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/art.png", atomically: true)
//            file.setTitle("New Test")
//            file.setLyrics("Yessir")
//            file.setArtist("What's good")
//            file.setAlbum("That's right")
//            
//            let art = NSImage(byReferencingFile: "/Users/Phil/Downloads/art.png")
//            
//            file.setArtwork(art!, isPNG: true)
            print(try file.getMP3Data())
            
//
//            print("Success:\t\(try file.writeTag())")
            
        }
        catch ID3EditErrors.FileDoesNotExist
        {
            print("Error: File Does Not Exist")
        }
        catch ID3EditErrors.NotAnMP3
        {
            print("Error: Not an MP3")
        }
        catch let e
        {
            print(e)
        }
    }


}


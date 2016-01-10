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
            let file = try MP3File(path: "/Users/Phil/Music/iTunes/iTunes Media/Music/Big Sean/What A Year/What A Year.mp3")
            
            // Test information parsing
            print("Title:\t\(file.getTitle())")
            print("Artist:\t\(file.getArtist())")
            print("Album:\t\(file.getAlbum())")
            print("Lyrics:\t\(file.getLyrics())")
//
//            // Save the artwork to the desktop
//            file.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/art.png", atomically: true)
//            //file.setLyrics(lyrics)
//            
//            let art = NSImage(byReferencingFile: "/Users/Phil/Downloads/art.png")
//            
//            file.setArtwork(art!, isPNG: true)
            
            
//            print("Success:\t\(file.writeTag())")
        }
        catch {}
    }


}


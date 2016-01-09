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
            
            // Save the artwork to the desktop
            file.getArtwork()?.TIFFRepresentation?.writeToFile("/Users/Phil/Desktop/art.png", atomically: true)
            
            // Test the tag creation
//            let lyrics = "[Big Sean:]\nLike, whoa, whoa\nSean Don, whoa\nBig boys\n\nLook, all I gotta say is what a year, what a year\nI decided now that every year is our year\nAw yeah man, that's 'til we disappear\nI'm focused on the near and never what's in the rear\nRecently I swear man we've had so many accolades\nI realized I ain't sat down, not even on a Saturday\nYeah I'm going overtime, O.T like it's TNT\nIn South America rocking Rio with RiRi\nYou know that's, stadium status\nWhen you started underground, you gotta make it to the attics\nSo I'm up in addict Focus, money is the only time I ADD\nGoing off more than ADT, making power moves like: back, forward, punch, kick, A, B, B\nBoy this shit ABC's, shout out Detail, 7-11 we on the road\nI'm on the sixth record off the album going gold\nLast one woke they ass up like the morning show\nI'm tryna make next year the greatest story ever told\nLike, shit, goddamn, standing next to Jay and K, like man\nNever took an L and I'm out there from where it's hard to make it this far when you this tan\nI'm sayin' I'm Lil B with the right wrist\nI realized time make money, it's priceless\nSo don't gas me up bitch, I'm a hybrid\nI know you like it, I see the job's done before I see my eyelids\nIt's getting better every single day, that's what they told me\nAnd I already wasn't fuckin' with the old me\n\n[Detail & Pharrell:]\nIt's like I hit the light switch\nWoah, yeah\nI feel like I hit the light switch (yeah)\nIt's like I took my family into a new crib\nThen I hit the light switch\nI took my whole life and then I hit the light switch (Aww yeah)\nSo I'mma hop out and roll on 'em (Yeah)\nHop out and roll on 'em\nIt's like a fresh pair of dice but I'm rolling on they life\nI'mma roll on 'em (Yeah, say what?)\nHop out and roll on 'em\n(I got the light switch, light switch)\n\n[Big Sean:]\nLook, what's life without risk?\nIf you take none, that's probably what you gonna get\nThis year I'm done with crazy hoes\nIf it's one thing I hate it's lazy hoes\nGoddamn, if it's two things I hate, it's greedy hoes\nOne time for my girls that turn theyself into CEOs\nJust know that you the finest\nI like older girls that realize they got time left\nI like young girls, but not girls young-minded\nOnes that shine with you but they won't get blinded\nWe just went around the world in twenty-eight days\nShows selling more tickets than the matinees\nSold out everywhere, bad bitch cheer\nAll I gotta say is \"What a year, what a year\"\nUp late, two, three, tryna get the mic skills\nRiding 'round ATL, shout out my bro Mike-Will\nMaking sure the fam straight like they like they up in Mike will\nEvery Mike, Jordan, Tyson, Jackson\nNeed the, uh, Washingtons, Franklins, Jacksons\nGot the crowd packed in, front in, back in\nLike oh, please stop comparing me\nYou starting up a new whip? I'm starting up a charity\nWhile you got new chains, my family out of debt nigga\nYeah, respect last longer than a check nigga\nRIP for my ones who couldn't see the day\nI really wish they would have saw me get a VMA\nI know my grandma ain't here but it's cool cause as long as I'm around she gon' be here in my DNA\nI went from broke to breaking records in the city where I live\nWhile I was breaking that down, they broke into the crib\nBut they can't break the dream shout to the ones I dreamed with\nI ain't rich 'til the whole team rich\nIt's like...\n\n[Detail & Pharrell:]\nI hit the light switch\nWoah, yeah\nI feel like I hit the light switch (Yeah)\nIt's like I took my family into a new crib\nThen I hit the light switch\nI took my whole life and then I hit the light switch (Aww yeah)\nSo I'mma hop out and roll on 'em (Yeah)\nHop out and roll on 'em\nIt's like a fresh pair of dice but I'm rolling on they life\nI'mma roll on 'em (Yeah, say what?)\nHop out and roll on 'em\n(I got the light switch, light switch)\n\n[Detail:]\nI got your bills\nPull out the 'Ville\nYou got the healing\nYou know you bad ass\nI got the light switch\nBaby you know, I got the light switch\nWoah"
            //file.setLyrics(lyrics)
            
//            let art = NSImage(byReferencingFile: "/Users/Phil/Downloads/art.jpg")!
            
//            file.setArtwork(art, isPNG: false)
            
            
//            print("Success:\t\(file.writeTag())")
        }
        catch {}
    }


}


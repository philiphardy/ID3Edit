# ID3Edit
## Description:
An easy to use Swift framework that edits and retrieves ID3 tag information.

## Important Information:
There are two projects which perform the same thing. One is in Swift the other in Objective C.
I recommend building the Objective C project and using that framework. (It will work for both
Objective C and Swift projects.) In the future, this will be the only project I update!

## Instructions:
Drag the framework into your Swift project. Make sure to add to your project's
embedded binaries by going to Project Settings > General > Embedded Binaries

At the top of your Swift code:
```swift
import ID3Edit
```

To open a mp3 file for writing:
```swift
do
{
   // Open the file
   let mp3File = try MP3File(path: "/Users/Example/Music/example.mp3")
   // Use MP3File(data: data) data being an NSData object
   // to load an MP3 file from memory
   // NOTE: If you use the MP3File(data: NSData?) initializer make
   //       sure to set the path before calling writeTag() or an
   //       exception will be thrown

   // Get song information
   print("Title:\t\(mp3File.getTitle())")
   print("Artist:\t\(mp3File.getArtist())")
   print("Album:\t\(mp3File.getAlbum())")
   print("Lyrics:\n\(mp3File.getLyrics())")
                                                   
   let artwork = mp3File.getArtwork()

   // Write song information
   mp3File.setTitle("The new song title")
   mp3File.setArtist("The new artist")
   mp3File.setAlbum("The new album")
   mp3File.setLyrics("Yeah Yeah new lyrics")

   if let newArt = NSImage(contentsOfFile: "/Users/Example/Pictures/example.png")
   {
          mp3File.setArtwork(newArt, isPNG: true)
   }
   else
   {
          print("The artwork referenced does not exist.")
   }

   // Save the information to the mp3 file
   mp3File.writeTag() // or mp3.getMP3Data() returns the NSData
                      // of the mp3 file
}
catch ID3EditErrors.FileDoesNotExist
{
   print("The file does not exist.")
}
catch ID3EditErrors.NotAnMP3
{
   print("The file you attempted to open was not an mp3 file.")
}
catch {}
```

## Instructions for Command Line Tools:
Drag the framework into your project. Make sure to add the path to the 
framework in Project Settings > Build Settings > Runpath Search Paths

# ID3Edit
### Author: Philip Hardy

## Description:
An easy to use Swift framework that edits and retrieves ID3 tag information.

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
   mp3File.writeTag()
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
...that's it! Pretty simple, right?

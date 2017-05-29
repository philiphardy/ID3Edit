//
//    MP3File.h
//    ID3Edit
//
//    Created by Philip Hardy on 5/26/17.
//
//    Copyright (c) 2017 Philip Hardy
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

#ifndef MP3File_h
#define MP3File_h

@interface MP3File : NSObject

- (id)initWithPath:(NSString*)path overwriteTag:(bool)overwrite;
- (id)initWithData:(NSData*)data overwriteTag:(bool)overwrite;

/** Returns the album of the song. */
- (NSString*)getAlbum;

/** Returns the artist of the song. */
- (NSString*)getArtist;

/** Returns the album artwork of the song. */
- (NSImage*)getArtwork;

/** Returns the lyrics of the song. */
- (NSString*)getLyrics;

/** 
 Returns the MP3 file data with the new tag included.
 Note: This data is ready to write to a file.
 */
- (NSData*)getMP3Data;

/** Returns the title of the song. */
- (NSString*)getTitle;

/** 
 Sets the album of the song.
 @param album The album to save.
 */
- (void)setAlbum:(NSString*)album;

/**
 Sets the artist of the song.
 @param artist The artist to save.
 */
- (void)setArtist:(NSString*)artist;

/**
 Sets the artwork of the song.
 @param artwork The image to save as the artwork.
 @param isPNG true if the image is a PNG, false otherwise.
 */
- (void)setArtwork:(NSImage*)artwork isPNG:(bool)isPNG;

/**
 Sets the lyrics of the song.
 @param lyrics The lyrics to save.
 */
- (void)setLyrics:(NSString*)lyrics;

/**
 Sets the file path for the mp3 file to be written.
 @param path The file path to write the mp3 file.
 */
- (void)setPath:(NSString*)path;

/** Sets the title of the song.
 @param title The title to save.
 */
- (void)setTitle:(NSString*)title;

/**
 Write the tag to the given path.
 @return true if it writes successfully, false otherwise
 */
- (bool)writeTag;

@end

#endif /* MP3File_h */

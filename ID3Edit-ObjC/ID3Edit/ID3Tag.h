//
//    ID3Tag.h
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

#ifndef ID3Tag_h
#define ID3Tag_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AlbumArtwork.h"
#import "Constants.h"
#import "Toolbox.h"

@interface ID3Tag : NSObject

- (NSString*)getAlbum;
- (NSMutableData*)getBytes;
- (NSString*)getArtist;
- (NSImage*)getArtwork;
- (NSString*)getLyrics;
- (NSString*)getTitle;
- (void)setAlbum:(NSString*)album;
- (void)setArtist:(NSString*)artist;
- (void)setArtwork:(NSImage*)artwork isPNG:(bool)isPNG;
- (void)setArtworkFromData:(NSData*)artData isPNG:(bool)isPNG;
- (void)setLyrics:(NSString*)lyrics;
- (void)setTitle:(NSString*)title;

@end

#endif /* ID3Tag_h */

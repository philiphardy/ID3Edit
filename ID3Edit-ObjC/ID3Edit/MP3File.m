//
//    MP3File.m
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


#import <Foundation/Foundation.h>
#import "Constants.h"
#import "ID3Tag.h"
#import "TagParser.h"
#import "MP3File.h"

@implementation MP3File {
    // MARK: - Instance variables
    NSData      *_data;
    TagParser   *_parser;
    NSString    *_path;
    ID3Tag      *_tag;
}

// MARK - Initializers
- (id)initWithPath:(NSString *)path overwriteTag:(bool)overwrite {
    // check the path extension
    if([[_path pathExtension] caseInsensitiveCompare:@"mp3"] != NSOrderedSame) {
        NSException *e = [NSException exceptionWithName:@"NotAnMp3Exception"
                                                 reason:@"The path given is not an mp3"
                                               userInfo:nil];
        @throw e;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    id this = [self initWithData:data overwriteTag:overwrite];
    
    _path = path;
    
    return this;
}

- (id)initWithData:(NSData *)data overwriteTag:(bool)overwrite {
    self = [super init];
    
    if(self) {
        _data = data;
        if(data == nil) {
            NSException *e = [NSException exceptionWithName:@"NoDataException"
                                                     reason:@"There is no data to read/examine"
                                                   userInfo:nil];
            @throw e;
        }
        else {
            _tag = [[ID3Tag alloc] init];
            _parser = [[TagParser alloc] init:data withTag:_tag];
            
            if(!overwrite) [_parser analyzeData];
        }
    }
    
    return self;
}

// MARK: - Accessor Methods
- (NSString*)getAlbum {
    return [_tag getAlbum];
}

- (NSString*)getArtist {
    return [_tag getArtist];
}

- (NSImage*)getArtwork {
    return [_tag getArtwork];
}

- (NSString*)getLyrics {
    return [_tag getLyrics];
}

- (NSData*)getMP3Data {
    if(_data == nil) {
        NSException *e = [NSException exceptionWithName:@"NoDataExistsException"
                                                 reason:@"No file data has been given"
                                               userInfo:nil];
        @throw e;
    }
    
    // get the tag bytes
//    NSArray *tagBytes = [_tag getBytes];
    NSMutableData *tagBytes = [_tag getBytes];
    
    if(tagBytes.length == 0) {
        // no tag to create, just return the music data
        return _data;
    }
    else if(tagBytes.length > 0x0FFFFFFF) {
        NSException *e = [NSException exceptionWithName:@"TagSizeOverflowException"
                                                 reason:@"The size of the tag is too big"
                                               userInfo:nil];
        @throw e;
    }
    
    // form the binary data for a new mp3 file
    NSMutableData *newData = [NSMutableData dataWithData:tagBytes];
    
    int tagSize;
    if([_parser isTagPresent]) {
        tagSize = [_parser getTagSize] + TAG_OFFSET;
    }
    else {
        tagSize = 0;
    }
    
    const uint8 *musicStartPtr = [_data bytes] + tagSize;
    u_long musicLength = [_data length] - tagSize;
    
    [newData appendBytes:musicStartPtr length:musicLength];
    
    return newData;
}

- (NSString*)getTitle {
    return [_tag getTitle];
}

// MARK: - Mutator Methods
- (void)setAlbum:(NSString*)album {
    [_tag setAlbum:album];
}

- (void)setArtist:(NSString*)artist {
    [_tag setArtist:artist];
}

- (void)setArtwork:(NSImage*)artwork isPNG:(bool)isPNG {
    [_tag setArtwork:artwork isPNG:isPNG];
}

- (void)setLyrics:(NSString *)lyrics {
    [_tag setLyrics:lyrics];
}

- (void)setPath:(NSString *)path {
    _path = path;
}

- (void)setTitle:(NSString*)title {
    [_tag setTitle:title];
}

- (bool)writeTag {
    if(_path == nil) {
        // no path is set, prevent writing
        NSException *e = [NSException exceptionWithName:@"NoPathSetException"
                                                 reason:@"No path has been set. The mp3 data cannot be written."
                                               userInfo:nil];
        @throw e;
    }
    
    NSData *newData = [self getMP3Data];
        
    // write the tag to the path
    return [newData writeToFile:_path atomically:true];
}

@end

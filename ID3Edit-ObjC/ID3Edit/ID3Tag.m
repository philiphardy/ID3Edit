//
//    ID3Tag.m
//    ID3Edit
//
//    Created by Philip Hardy on 5/27/17.
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

#import "ID3Tag.h"

@implementation ID3Tag {
    // MARK: - Instance Variables
    NSString *_album;
    NSString *_artist;
    NSString *_lyrics;
    NSString *_title;
    AlbumArtwork *_artwork;
}

// MARK: - Accessor Methods
- (NSString*)getAlbum {
    return _album;
}

- (NSString*)getArtist {
    return _artist;
}

- (NSString*)getLyrics {
    return _lyrics;
}

- (NSString*)getTitle {
    return _title;
}

- (NSMutableData*)getBytes {
//    NSMutableArray *content = [[NSMutableArray alloc] init];
    NSMutableData *content = [[NSMutableData alloc] init];
    
    if([self infoExists:_artist]) {
        // Create the artist frame
        NSArray *frame = [self createFrame:V2_ARTIST withContent:_artist];
        [self addByteArrayToData:frame data:content];
    }
    
    if([self infoExists:_title]) {
        // Create the title frame
        NSArray *frame = [self createFrame:V2_TITLE withContent:_title];
        [self addByteArrayToData:frame data:content];
    }
    
    if([self infoExists:_album]) {
        // Create the album frame
        NSArray *frame = [self createFrame:V2_ALBUM withContent:_album];
        [self addByteArrayToData:frame data:content];
    }
    
    if([self infoExists:_lyrics]) {
        // Create the lyrics frame
        NSArray *frame = [self createLyricFrame];
        [self addByteArrayToData:frame data:content];
    }
    
    if([_artwork getData] != nil) {
        // Create the artwork frame
        NSArray *frame = [self createArtFrame];
        [self addByteArrayToData:frame data:content];
    }
    
    if(content.length == 0) {
        // Prevent writing tag if no song info is present
        return content;
    }
    
    // Make the tag header
    NSMutableData *header = [[NSMutableData alloc] init];
    [self addByteArrayToData:[self createTagHeader:(uint32)content.length] data:header];
    [header appendData:content];
//    NSMutableArray *header = [self createTagHeader:(uint32)content.count];
//    [header addObjectsFromArray:content];
    
    return header;
}

- (NSImage*)getArtwork {
    return [[NSImage alloc] initWithData:[_artwork getData]];
}

// MARK: - Mutator Methods
- (void)setAlbum:(NSString*)album {
    _album = [Toolbox removePadding:album];
}

- (void)setArtist:(NSString*)artist {
    _artist = [Toolbox removePadding:artist];
}

- (void)setArtwork:(NSImage*)artwork isPNG:(bool)isPNG {
    NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithData:[artwork TIFFRepresentation]];
    NSDictionary *properties = @{NSImageCompressionFactor: @0.5};
    
    if(isPNG) {
        _artwork = [[AlbumArtwork alloc] initWithData:[imgRep representationUsingType:NSPNGFileType properties:properties]
                                                isPNG:isPNG];
    }
    else {
        _artwork = [[AlbumArtwork alloc] initWithData:[imgRep representationUsingType:NSJPEGFileType properties:properties]
                                                isPNG:isPNG];
    }
}

- (void)setArtworkFromData:(NSData*)artData isPNG:(bool)isPNG {
    _artwork = [[AlbumArtwork alloc] initWithData:artData isPNG:isPNG];
}

- (void)setLyrics:(NSString *)lyrics {
    _lyrics = [Toolbox removePadding:lyrics];
}

- (void)setTitle:(NSString*)title {
    _title = [Toolbox removePadding:title];
}

// MARK: - Tag Creation
- (NSArray*)createFrame:(NSArray*)frame withContent:(NSString*)str {
    NSMutableArray *bytes = [[NSMutableArray alloc] initWithArray:frame];
    const char *strPtr = [str UTF8String];
    NSMutableArray *content = [[NSMutableArray alloc] init];
    
    // Move past the padding in the beginning of the string
    while(*strPtr == '\0') {
        strPtr++;
    }
    
    // Add padding to beginning
    [content addObject:@((uint8)0)];
    
    // Copy the string to a new buffer
    while(*strPtr != '\0') {
        [content addObject:@(*(strPtr++))];
    }
    
    // Add padding to end character
    [content addObject:@((uint8)0)];
    
    NSMutableArray *sizeArr = [Toolbox toByteArray:(uint32)content.count];
    [sizeArr removeObjectAtIndex:0];
    
    // Create the frame
    [bytes addObjectsFromArray:sizeArr];
    [bytes addObjectsFromArray:content];
    
    return bytes;
}

- (NSArray*)createLyricFrame {
    NSMutableArray *bytes = [[NSMutableArray alloc] initWithArray:V2_LYRICS];
    NSArray *encoding = @[@((uint8)0x00), @((uint8)0x65), @((uint8)0x6E), @((uint8)0x67), @((uint8)0x00)];
    NSMutableArray *content = [[NSMutableArray alloc] init];
    const char *lyricsPtr = [_lyrics UTF8String];
    
    // Copy the contents of the string to the content array
    do {
        [content addObject:@(*lyricsPtr)];
    } while(*(lyricsPtr++) != '\0');
    
    NSMutableArray *sizeArr = [Toolbox toByteArray:(uint32)(encoding.count + content.count)];
    [sizeArr removeObjectAtIndex:0];
    
    // Form the header
    [bytes addObjectsFromArray:sizeArr];
    [bytes addObjectsFromArray:encoding];
    [bytes addObjectsFromArray:content];
    
    return bytes;
}

- (NSArray*)createArtFrame {
    NSMutableArray *bytes = [[NSMutableArray alloc] initWithArray:V2_ARTWORK];
    
    // Calculate size
    NSMutableArray *sizeArr = [Toolbox toByteArray:(uint32)([_artwork getData].length + 6)];
    [sizeArr removeObjectAtIndex:0];
    
    [bytes addObjectsFromArray:sizeArr];
    
    // Append encoding
    if(_artwork.isPNG) {
        // PNG encoding
        [bytes addObjectsFromArray:@[@((uint8)0x00), @((uint8)0x50), @((uint8)0x4E), @((uint8)0x47), @((uint8)0x00), @((uint8)0x00)]];
    }
    else {
        // JPG encoding
        [bytes addObjectsFromArray:@[@((uint8)0x00), @((uint8)0x4A), @((uint8)0x50), @((uint8)0x47), @((uint8)0x00), @((uint8)0x00)]];
    }
    
    // Add artwork data
    const uint8 *artPtr = (const uint8*)[_artwork getData].bytes;
    for(int i = 0; i < [_artwork getData].length; i++) {
        [bytes addObject:@(artPtr[i])];
    }
    
    return bytes;
}

- (NSMutableArray*)createTagHeader:(uint32)contentSize {
    NSMutableArray *bytes = [[NSMutableArray alloc] initWithArray:V2_HEADER];
    uint32 formattedSize = [self calcSize:contentSize];
    
    [bytes addObjectsFromArray:[Toolbox toByteArray:formattedSize]];
    
    return bytes;
}

- (uint32)calcSize:(uint32)size {
    uint32 formedSize = 0;
    
    for(int i = 0; i < 4; i++) {
        int shift = i * 8;
        int mask = 0xFF << shift;
        int byte = (size & mask) >> shift;
        
        uint8 oMask = 0x80;
        for(int j = 0; j < i; j++) {
            // Create the overflow mask
            oMask >>= 1;
            oMask += 0x80;
        }
        
        // left side of the byte
        uint8 overflow = ((uint8)byte) & oMask;
        
        // right side of the byte
        uint8 untouched = ((uint8)byte) & ~oMask;
        
        // Store the byte
        byte = ((((int)overflow) << 1) + ((int)untouched)) << (shift + i);
        formedSize += byte;
    }
    
    return formedSize;
}

- (bool)infoExists:(NSString*)category {
    return ![category isEqualToString:@""];
}

- (void)addByteArrayToData:(NSArray*)array data:(NSMutableData*)data {
    for(int i = 0; i < array.count; i++) {
        const char c = [array[i] unsignedCharValue];
        [data appendBytes:&c length:1];
    }
}

@end






























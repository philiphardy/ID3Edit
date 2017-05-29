//
//    TagParser.m
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

#import "TagParser.h"

@implementation TagParser {
    NSData *_data;
    ID3Tag *_tag;
    uint8 _version;
}

// MARK: - Public Methods
- (id)init:(NSData*)data withTag:(ID3Tag*)tag {
    self = [super init];
    
    if(self) {
        _data = data;
        _tag = tag;
        
        // Make sure there is at least 4 bytes of data
        if(data.length >= 4) {
            _version = ((uint8*)data.bytes)[VERSION_OFFSET];
        }
    }
    
    return self;
}

- (void)analyzeData {
    if([self isTagPresent]) {
        [self extractInfoFromFrames];
    }
}

- (bool)isTagPresent {
    const uint8 *bytes = (const uint8*)_data.bytes;
    bool isPresent = false;
    
    for(int i = 0; i < 3; i++) {
        isPresent = isPresent || bytes[i] == [V2_HEADER[i] unsignedCharValue] ||
                                 bytes[i] == [V3_HEADER[i] unsignedCharValue];
    }
    
    return isPresent;
}

- (uint32)getTagSize {
    uint32 size = CFSwapInt32HostToBig(*(const uint32*)(_data.bytes + TAG_SIZE_OFFSET));
    uint32 b1 = (size & 0x7F000000) >> 3;
    uint32 b2 = (size & 0x007F0000) >> 2;
    uint32 b3 = (size & 0x00007F00) >> 1;
    uint32 b4 =  size & 0x0000007F;
    
    return b1 + b2 + b3 + b4;
}

// MARK: - Private Methods
- (bool)isUseful:(NSArray*)frame {
    // Determine if the frame is useful
    return  [self isArtistFrame:frame]    ||
            [self isTitleFrame:frame]     ||
            [self isAlbumFrame:frame]     ||
            [self isArtworkFrame:frame]   ||
            [self isLyricsFrame:frame];
}

- (bool)isArtistFrame:(NSArray*)frame {
    if(_version == 2) {
        return [frame isEqualToArray:V2_ARTIST];
    }
    
    return [frame isEqualToArray:V3_ARTIST];
}

- (bool)isTitleFrame:(NSArray*)frame {
    if(_version == 2) {
        return [frame isEqualToArray:V2_TITLE];
    }
    
    return [frame isEqualToArray:V3_TITLE];
}

- (bool)isAlbumFrame:(NSArray*)frame {
    if(_version == 2) {
        return [frame isEqualToArray:V2_ALBUM];
    }
    
    return [frame isEqualToArray:V3_ALBUM];
}

- (bool)isArtworkFrame:(NSArray*)frame {
    if(_version == 2) {
        return [frame isEqualToArray:V2_ARTWORK];
    }
    
    return [frame isEqualToArray:V3_ARTWORK];
}

- (bool)isLyricsFrame:(NSArray*)frame {
    if(_version == 2) {
        return [frame isEqualToArray:V2_LYRICS];
    }
    
    return [frame isEqualToArray:V3_LYRICS];
}

- (void)extractInfoFromFrames {
    uint32 tagSize = [self getTagSize];
    const uint8 *ptr = ((const uint8*)_data.bytes) + TAG_OFFSET;
    
    // Loop through all the frames
    uint32 curPos = 0;
    while(curPos < tagSize) {
        const uint8 * const bytes = ptr + curPos;
        NSArray *frameBytes;
        uint32 frameSize;
        
        if(_version == 2) {
            frameBytes = @[@(bytes[0]), @(bytes[1]), @(bytes[2])];
            frameSize = [self getFrameSize:bytes withOffset:2];
        }
        else {
            frameBytes = @[@(bytes[0]), @(bytes[1]), @(bytes[2]), @(bytes[3])];
            frameSize = [self getFrameSize:bytes withOffset:4];
        }
        
        // Extract info from current frame if needed
        if([self isUseful:frameBytes]) {
            [self extractInfo:bytes withFrameSize:frameSize andFrameBytes:frameBytes];
        }
        
        // Check for padding
        else if(frameBytes[0] == 0 && frameBytes[1] == 0 && frameBytes[2] == 0) {
            break;
        }
        
        // Move the current position up to the next frame
        curPos += frameSize;
    }
}

- (void)extractInfo:(const uint8*)bytes withFrameSize:(uint32)frameSize andFrameBytes:(NSArray*)frameBytes {
    uint32 frameOffset = [self getFrameOffset];
    
    if([self isArtistFrame:frameBytes]) {
        // Store artist
        NSString *content = [[NSString alloc] initWithBytes:bytes + frameOffset
                                                     length:frameSize - frameOffset
                                                   encoding:NSASCIIStringEncoding];
        [_tag setArtist:content];
    }
    else if([self isTitleFrame:frameBytes]) {
        // Store title
        NSString *content = [[NSString alloc] initWithBytes:bytes + frameOffset
                                                     length:frameSize - frameOffset
                                                   encoding:NSASCIIStringEncoding];
        [_tag setTitle:content];
    }
    else if([self isAlbumFrame:frameBytes]) {
        // Store album
        NSString *content = [[NSString alloc] initWithBytes:bytes + frameOffset
                                                     length:frameSize - frameOffset
                                                   encoding:NSASCIIStringEncoding];
        [_tag setAlbum:content];
    }
    else if([self isLyricsFrame:frameBytes]) {
        // Store lyrics
        frameOffset += 5;
        NSString *content = [[NSString alloc] initWithBytes:bytes + frameOffset
                                                     length:frameSize - frameOffset
                                                   encoding:NSASCIIStringEncoding];
        [_tag setLyrics:content];
    }
    else {
        // Store artwork
        const NSArray *JPG_ID = @[@0xFF, @0xD8, @0xFF, @0xE0];
        const NSArray *PNG_ID = @[@0x89, @0x50, @0x4E, @0x47];
        const uint8 *ptr = bytes + frameOffset;
        bool isPNG = true;
        
        for(uint32 i = 0; i <= frameSize; i++) {
            if  ((ptr[0] == [JPG_ID[0] unsignedCharValue]) && (ptr[1] == [JPG_ID[1] unsignedCharValue]) &&
                 (ptr[2] == [JPG_ID[2] unsignedCharValue]) && (ptr[3] == [JPG_ID[3] unsignedCharValue])) {
                // JPG binary data found
                isPNG = false;
                break;
            }
            else if ((ptr[0] == [PNG_ID[0] unsignedCharValue]) && (ptr[1] == [PNG_ID[1] unsignedCharValue]) &&
                     (ptr[2] == [PNG_ID[2] unsignedCharValue]) && (ptr[3] == [PNG_ID[3] unsignedCharValue])) {
                // PNG binary data found
                break;
            }
            
            ptr++;
        }
        
        NSData *artData = [[NSData alloc] initWithBytes:ptr length:frameSize - (ptr - bytes)];
        [_tag setArtworkFromData:artData isPNG:isPNG];
    }
}

- (uint32)getFrameSize:(const uint8*)framePtr withOffset:(uint32)offset {
    // Calculate the size of the frame
    uint32 size = CFSwapInt32HostToBig(*(uint32*)(framePtr + offset));
    
    if(_version == 2) {
        // Extract the first 3 bytes
        size &= 0x00FFFFFF;
    }
    
    // Return the frame size including the frame header
    return size + [self getFrameOffset];
}

- (uint32)getFrameOffset {
    if(_version == 2) {
        return V2_FRAME_OFFSET;
    }
    
    return V3_FRAME_OFFSET;
}

@end

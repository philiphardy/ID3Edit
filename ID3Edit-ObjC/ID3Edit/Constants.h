//
//    Constants.h
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

#ifndef Constants_h
#define Constants_h

#define BYTE                8
#define VERSION_OFFSET      3
#define TAG_SIZE_OFFSET     6
#define TAG_OFFSET          10
#define ART_FRAME_OFFSET    12
#define LYRICS_FRAME_OFFSET 11

// FRAMES
#define V2_FRAME_OFFSET     6
#define V2_ALBUM            @[@((uint8)0x54), @((uint8)0x41), @((uint8)0x4C)]
#define V2_ARTIST           @[@((uint8)0x54), @((uint8)0x50), @((uint8)0x31)]
#define V2_ARTWORK          @[@((uint8)0x50), @((uint8)0x49), @((uint8)0x43)]
#define V2_HEADER           @[@((uint8)0x49), @((uint8)0x44), @((uint8)0x33), @((uint8)0x02), @((uint8)0x00), @((uint8)0x00)]
#define V2_LYRICS           @[@((uint8)0x55), @((uint8)0x4C), @((uint8)0x54)]
#define V2_TITLE            @[@((uint8)0x54), @((uint8)0x54), @((uint8)0x32)]

#define V3_FRAME_OFFSET     10
#define V3_ALBUM            @[@((uint8)0x54), @((uint8)0x41), @((uint8)0x4C), @((uint8)0x42)]
#define V3_ARTIST           @[@((uint8)0x54), @((uint8)0x50), @((uint8)0x45), @((uint8)0x31)]
#define V3_ARTWORK          @[@((uint8)0x41), @((uint8)0x50), @((uint8)0x49), @((uint8)0x43)]
#define V3_HEADER           @[@((uint8)0x49), @((uint8)0x44), @((uint8)0x33), @((uint8)0x03), @((uint8)0x00), @((uint8)0x00)]
#define V3_LYRICS           @[@((uint8)0x55), @((uint8)0x53), @((uint8)0x4C), @((uint8)0x54)]
#define V3_TITLE            @[@((uint8)0x54), @((uint8)0x49), @((uint8)0x54), @((uint8)0x32)]

#endif /* Constants_h */

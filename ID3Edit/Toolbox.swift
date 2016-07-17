//
//  Toolbox.swift
//  ID3Edit
//
//    MIT License
//
//    Copyright (c) 2016 Philip Hardy
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

typealias Byte = UInt8;

internal class Toolbox
{
    internal static func toByteArray<T>(inout num: T) -> [Byte]
    {
        // Get pointer to number
        let ptr = withUnsafePointer(&num) {
            UnsafePointer<Byte>($0);
        }
        
        // The array to store the bytes
        var bytes: [Byte] = [];
        
        for i in (0 ..< sizeof(T)).reverse()
        {
            bytes.append(ptr[i]);
        }
        
        return bytes;
    }
    
    internal static func removePadding(str: String) -> String
    {
        var buffer = [Byte](str.utf8);
        
        // Remove padding from front
        while buffer.first == 0
        {
            buffer.removeFirst();
        }
        
        // Remove padding from end
        while buffer.last == 0
        {
            buffer.removeLast();
        }
        
        return NSString(bytes: UnsafePointer<Byte>(buffer), length: buffer.count, encoding: NSASCIIStringEncoding) as! String;
    }
}

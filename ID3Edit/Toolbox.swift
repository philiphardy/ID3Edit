//
//  Toolbox.swift
//  ID3Edit
//
//  Created by Philip Hardy on 6/12/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

typealias Byte = UInt8

internal class Toolbox
{
    internal static func toByteArray<T>(inout num: T) -> [Byte]
    {
        // Get pointer to number
        let ptr = withUnsafePointer(&num) {
            UnsafePointer<Byte>($0)
        }
        
        // The array to store the bytes
        var bytes: [Byte] = []
        
        for i in (0 ..< sizeof(T)).reverse()
        {
            bytes.append(ptr[i])
        }
        
        return bytes
    }
}
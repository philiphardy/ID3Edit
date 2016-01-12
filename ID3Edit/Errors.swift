//
//  Errors.swift
//  ID3Edit
//
//  Created by Philip Hardy on 1/6/16.
//  Copyright © 2016 Hardy Creations. All rights reserved.
//

public enum ID3EditErrors: ErrorType
{
    case NotAnMP3
    case FileDoesNotExist
    case NoDataExists
    case TagSizeOverflow
    case NoPathSet
}

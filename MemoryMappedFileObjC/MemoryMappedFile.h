//
//  MemoryMappedFile.h
//  MemoryMappedFileExample
//
//  http://memfrag.se/blog/Memory-Mapped-Files
//
//  Created by Troy Stribling on 8/15/15.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

#import <Foundation/Foundation.h>

#ifndef MemoryMappedFile_h
#define MemoryMappedFile_h

@interface MemoryMappedFile : NSObject {
@private
    NSString *path;
    void *baseAddress;
    NSUInteger size;
}

// The path of the file to map into memory.
@property (nonatomic, readonly) NSString *path;

// The memory address where the file is mapped.
// NULL when the file is not mapped into memory.
@property (nonatomic, readonly) void *baseAddress;

// Total size of the file.
@property (nonatomic, readonly) NSUInteger size;

// Returns YES when the file is mapped into memory.
@property (nonatomic, readonly) BOOL isMapped;

// Prepares to map the specified file, but does not
// actually map the file into memory.
- (id)initWithPath:(NSString *)pathToFile;

// Maps the file into memory.
// Returns pointer to start of file or NULL if unsuccessful.
- (void *)map;

// Unmaps the file from memory.
// The pointer returned by map is no longer valid.
- (void)unmap;

@end


#endif /* MemoryMappedFile_h */

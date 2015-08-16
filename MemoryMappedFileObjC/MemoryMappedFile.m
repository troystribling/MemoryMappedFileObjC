//
//  MemoryMappedFile.m
//  MemoryMappedFileExample
//
//  http://memfrag.se/blog/Memory-Mapped-Files
//
//  Created by Troy Stribling on 8/15/15.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

#import "MemoryMappedFile.h"
#import <fcntl.h>
#import <unistd.h>
#import <sys/stat.h>
#import <sys/mman.h>

@implementation MemoryMappedFile

@synthesize path;
@synthesize baseAddress;
@synthesize size;

- (id)initWithPath:(NSString*)pathToFile {
    if (self = [super init]) {
        path = [pathToFile copyWithZone:nil];
    }
    
    return self;
}

- (void)dealloc {
    if ([self isMapped]) {
        [self unmap];
    }
}

- (void*)map {
    if ([self isMapped]) {
        return baseAddress;
    }
    
    // This will be released when "path" is released.
    const char *cPath = [path cStringUsingEncoding:NSISOLatin1StringEncoding];
    
    // The file must be opened so we can pass
    // the file descriptor to mmap().
    int file = open(cPath, O_RDONLY);
    if (file == -1) {
        perror("open");
        return NULL;
    }
    
    // Get info about file, we need the file size.
    struct stat buffer;
    if (fstat(file, &buffer) == -1) {
        perror("fstat");
        close(file);
        return NULL;
    }
    
    // Map the file as read only pages.
    baseAddress = mmap(NULL, buffer.st_size, PROT_READ,MAP_SHARED, file, 0);
    if (baseAddress == MAP_FAILED) {
        perror("mmap");
        close(file);
        return NULL;
    }
    
    // Store the size, we need it when we unmap the file.
    size = (NSUInteger)buffer.st_size;
    
    // It's ok to close() after mmap().
    if (close(file) == -1) {
        perror("close");
        [self unmap];
        return NULL;
    }
    
    return baseAddress;
}

- (void)unmap {
    // Only unmap the file if it is actually mapped.
    if ([self isMapped]) {
        if (munmap(baseAddress, size) == -1) {
            perror("munmap");
        }
        baseAddress = NULL;
        size = 0;
    }
}

- (BOOL)isMapped {
    return baseAddress != NULL;
}

@end
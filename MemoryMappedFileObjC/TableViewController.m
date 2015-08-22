//
//  TableViewController.m
//  MemoryMappedFileObjC
//
//  Created by Troy Stribling on 8/16/15.
//  Copyright © 2015 Troy Stribling. All rights reserved.
//

#import "TableViewController.h"
#import "MemoryMappedFile.h"

static NSString* filePath = @"data.bin";
static const UInt64 rows = 100;

typedef struct {
    UInt64 i;
    char buffer[40];
} Data;

@interface TableViewController ()

@property(nonatomic, retain) MemoryMappedFile* mmFile;
@property(nonatomic) void* mmData;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rowsLabel.text = [[NSNumber numberWithUnsignedLongLong:rows] stringValue];
    if (![self fileExists]) {
        NSLog(@"%@ does not exist", [self filePath]);
        self.fileStatusLabel.text = @"Creating";
        [self createDataFile];
    } else {
        NSLog(@"%@ exists", [self filePath]);
        self.fileStatusLabel.text = @"Exists";
    }
    self.mmFile = [[MemoryMappedFile alloc] initWithPath:[self filePath]];
    if (self.mmFile ) {
        self.mmData = [self.mmFile map];
        self.fileStatusLabel.text = @"Mapped";
        self.rowSizeLabel.text = [NSString stringWithFormat:@"%lu", sizeof(Data)];
        self.rowsLabel.text = [NSString stringWithFormat:@"%lu", [self.mmFile size]/sizeof(Data)];
        self.fileSizeLabel.text = [NSString stringWithFormat:@"%lu", [self.mmFile size]];
        [self printMemoryMappedFile];
    } else {
        NSLog(@"Error mapping file");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (BOOL)fileExists {
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    return [fileMgr fileExistsAtPath:[self filePath]];
}

- (NSString*)filePath {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:filePath];
}

- (void)createDataFile {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager createFileAtPath:[self filePath] contents:nil attributes:nil]) {
        NSLog(@"File create failed");
        return;
    }
    NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath:[self filePath]];
    if (file == nil) {
        NSLog(@"File open failed");
        return;
    }
    Data row;
    for (UInt64 i=0; i < rows; i++) {
        row.i = i;
        NSString* uuid = [[NSUUID UUID] UUIDString];
        strcpy(row.buffer, [uuid cStringUsingEncoding:NSASCIIStringEncoding]);
        NSData* rowData = [NSData dataWithBytes:&row length:sizeof(row)];
        [file writeData:rowData];
    }
    self.fileStatusLabel.text = @"Exists";
    [file closeFile];
}

- (void)printDataFile {
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:[self filePath]];
    if (file == nil) {
        NSLog(@"File open failed");
        return;
    }
    Data row;
    for (UInt64 i = 0; i < rows; i++) {
        NSData* rowData = [file readDataOfLength:sizeof(row)];
        [rowData getBytes:&row length:sizeof(row)];
        NSLog(@"i=%llu, buffer=%s, buffer size=%lu", row.i, row.buffer, strlen(row.buffer));
    }
    
}

- (void)printMemoryMappedFile {
    Data *row;
    if (self.mmFile) {
        UInt64 rowSize = sizeof(Data);
        UInt64 nrows = self.mmFile.size / rowSize;
        NSLog(@"File size: %lu, rowSize:%llu, nrows:%llu", (unsigned long)self.mmFile.size, rowSize, nrows);
        for (UInt64 i = 0; i < nrows; i++) {
            NSLog(@"row number:%llu", i);
            row = (Data*)(self.mmData + i * rowSize);
            NSLog(@"i=%llu, buffer=%s, buffer size=%lu", row->i, row->buffer, strlen(row->buffer));
        }
    } else {
        NSLog(@"Error mapping file");
    }
    
}

@end

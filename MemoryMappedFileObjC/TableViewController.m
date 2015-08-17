//
//  TableViewController.m
//  MemoryMappedFileObjC
//
//  Created by Troy Stribling on 8/16/15.
//  Copyright © 2015 Troy Stribling. All rights reserved.
//

#import "TableViewController.h"

static NSString* filePath = @"data.bin";
static const UInt64 rows = 100;

typedef struct {
    UInt64 i;
    char buffer[40];
} Data;

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rowsLabel.text = [[NSNumber numberWithUnsignedLongLong:rows] stringValue];
    if ([self fileExists]) {
        NSLog(@"%@ exists", [self filePath]);
        self.fileStatusLabel.text = @"Exists";
        [self printDataFile];
    } else {
        NSLog(@"%@ does not exist", [self filePath]);
        [self createDataFile];
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
    self.fileStatusLabel.text = @"Creating";
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

@end

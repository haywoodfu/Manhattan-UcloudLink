//
//  FileHelper.m
//  QQMusicForIphoneDemo
//
//  Created by jordenwu-Mac on 10-8-20.
//  Copyright 2010 tencent.com. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper

+ (BOOL)fileExistsWithPath:(NSString *)filePath
{
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)createFileWithPath:(NSString *)filePath
{
	return [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
}

+ (BOOL)deleteFileWithPath:(NSString *)filePath
{
	return [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

+ (BOOL)createDirectoryWithPath:(NSString *)dirPath
{   
	return [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)directoryExistsWithPath:(NSString *)dirPath
{   
	BOOL isDir=YES;
	return [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
}

+ (BOOL)deleteDirectoryWithPath:(NSString *)dirPath
{  
	return [[NSFileManager defaultManager] removeItemAtPath:dirPath error:NULL];
}

+ (NSString *)getDocumentsPath
{   
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return (NSString *)[paths objectAtIndex:0];
}

+ (NSString *)getLibraryPath
{   
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);	
	return (NSString *)[paths objectAtIndex:0];
}

+ (NSString *)getADImagesPath
{
    NSString *path = [NSString stringWithFormat:@"%@/Caches/AdImages",[FileHelper getLibraryPath] ];
	return path;
}

+ (NSString *)getTemporaryPath
{   
	NSString *path = NSTemporaryDirectory();
	return path;
}

+ (unsigned long long)getFileSizeWithPath:(NSString*)filePath
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	return (unsigned long long)[[attributes objectForKey:NSFileSize] unsignedLongLongValue];
}

+ (unsigned long long)getFileSystemFreeSize{
	NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
	return [[fattributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
}

+ (void)moveFile:(NSString*)file ToNewFile:(NSString*)newFile
{
	[[NSFileManager defaultManager] moveItemAtPath:file toPath:newFile error:nil];
}

+ (void)copyFile:(NSString*)file ToNewFile:(NSString*)newFile
{
    @autoreleasepool {
        [[NSFileManager defaultManager] copyItemAtPath:file toPath:newFile error:nil];
    }
}

+(BOOL)isDiskFull{
    long long freespace = [FileHelper getFileSystemFreeSize];
    if(freespace < 1024*1024*560){
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)findFile:(NSString *)dictionary fileName:(NSString *)fileName{
//    system("find /Users/Haywoodfu/ -name '*.png'");
    NSError *error;
    NSArray *pathList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dictionary error:&error];
    for (NSString *t_path in pathList) {
        NSString * fullPath = [dictionary stringByAppendingPathComponent:t_path];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]) {         
            if ( isDir){
                if ([self findFile:fullPath fileName:fileName] != nil) {
                    return [fullPath stringByAppendingPathComponent:fileName];
                }
            }else if ([t_path isEqualToString:fileName]){
                return t_path;
            }
        }
    }
    return nil;
}

+(void)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath list:(NSMutableArray *)fileNameList
{
    if (fileNameList == nil) {
        return;
    }
    NSArray *tmpList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *fileName in tmpList) {
        NSString *fullPath = [dirPath stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir])
        {
            if (isDir) {
                [FileHelper getFilenamelistOfType:type fromDirPath:fullPath list:fileNameList];
            }else {
                if ([[[fileName pathExtension]lowercaseString] isEqualToString:[type lowercaseString]]) {
                    [fileNameList  addObject:fullPath];
                }
            }
        }
    }
}
@end

//
//  FileHelper.h
//  QQLiveHD
//
//  Created by jordenwu-Mac on 10-8-20.
//  Copyright 2010 tencent.com. All rights reserved.
#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/**
 * 文件管理的工具类
 */
@interface FileHelper : NSObject {

}

/**
 * 文件是否存在
 */
+ (BOOL)fileExistsWithPath:(NSString *)filePath;

/**
 * 创建文件
 */
+ (BOOL)createFileWithPath:(NSString *)filePath;

/**
 * 删除文件
 */
+ (BOOL)deleteFileWithPath:(NSString *)filePath;

/**
 * 创建目录
 */
+ (BOOL)createDirectoryWithPath:(NSString *)dirPath;

/**
 * 目录是否存在
 */
+ (BOOL)directoryExistsWithPath:(NSString *)dirPath;

/**
 * 删除目录
 */
+ (BOOL)deleteDirectoryWithPath:(NSString *)dirPath;

/**
 * 获取程序的Documents目录
 */
+ (NSString *)getDocumentsPath;

/**
 * 获取程序目录的Library目录路径
 */
+ (NSString *)getLibraryPath;

/**
 * 获取程序临时目录路径
 */
+ (NSString *)getTemporaryPath;

/**
 * 获取文件大小（以字节为单位）
 */
+ (unsigned long long)getFileSizeWithPath:(NSString*)filePath;

/**
 * 获取系统可用空间（以字节为单位）
 */
+ (unsigned long long)getFileSystemFreeSize;

/**
 * 移动文件
 */
+ (void)moveFile:(NSString*)file ToNewFile:(NSString*)newFile;

/**
 * 复制文件
 */
+ (void)copyFile:(NSString*)file ToNewFile:(NSString*)newFile;

/**
 * 判断文件空间是否已满（小于500MB）
 */
+(BOOL)isDiskFull;

/**
 *递归寻找指定文件名的文件
 */
+(NSString *)findFile:(NSString *)dictionary fileName:(NSString *)fileName;

/**
 *获取运营图片文件夹
 */
+ (NSString *)getADImagesPath;

/**
 *遍历文件夹获得指定文件类型的列表
 */
+(void)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath list:(NSMutableArray *)fileNameList;
@end

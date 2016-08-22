//
//  ZWDownloadCenter.m
//  Paper
//
//  Created by Administrator on 16/3/27.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDownloadCenter.h"
#import "ZWUtilsCenter.h"
#import "NSString+URLEncode.h"
#import "AppDelegate.h"
#import "NSDate+CommomDate.h"

static NSString *const ConfigurationIdentifier = @"ZWDownloadCenteridentifier";

static ZWDownloadCenter *downloadCenter = nil;

@interface ZWDownloadCenter ()

@property (nonatomic, strong) NSMutableArray *files;

@property (nonatomic, strong) FMDatabaseQueue *DBQueue;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *downloadTasks;

@property (nonatomic, strong) NSMutableArray *completions;

@property (nonatomic, strong) NSMutableArray *downloading;

@property (nonatomic, strong) NSMutableArray *resumeDatas;

@property (nonatomic, copy) NSString *resumeFile;

@end

@implementation ZWDownloadCenter

- (NSMutableArray *)files {
    if (_files == nil) {
        _files = [NSMutableArray array];
    }
    return _files;
}

- (NSString *)resumeFile {
    if (_resumeFile == nil) {
        _resumeFile = [[ZWUtilsCenter resumeDataDirectory] stringByAppendingPathComponent:@"ResumeData.archive"];
    }
    return _resumeFile;
}

- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (NSMutableArray *)downloadTasks {
    if (_downloadTasks == nil) {
        _downloadTasks = [NSMutableArray array];
    }
    return _downloadTasks;
}

- (NSMutableArray *)completions {
    if (_completions == nil) {
        _completions = [NSMutableArray array];
    }
    return _completions;
}

- (NSMutableArray *)downloading {
    if (_downloading == nil) {
        _downloading = [NSMutableArray array];
    }
    return _downloading;
}


- (FMDatabaseQueue *)DBQueue {
    if (_DBQueue == nil) {
        _DBQueue = [(AppDelegate *)[UIApplication sharedApplication].delegate DBQueue];
    }
    return _DBQueue;
}

- (NSMutableArray *)resumeDatas {
    if (_resumeDatas == nil) {
        _resumeDatas = [NSMutableArray array];
    }
    return _resumeDatas;
}


+ (ZWDownloadCenter *)sharedDownloadCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadCenter = [[self alloc] init];
    });
    return downloadCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"Normal initializtion");
    }
    return self;
}

- (void)addDownloadTaskWithFile:(ZWFile *)file beforeDownload:(BeforeBlock)before whileDonwloading:(DownloadingBlock)downloading afterDownload:(CompleteBlock)completion{
    
    if (self.session == nil) {
        NSLog(@"session is nil");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (before) {
            before();
        }
    });
    
    NSLog(@"添加任务: %@", file.url);
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:[file.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.files addObject:file];
    [self.downloadTasks addObject:downloadTask];
    [self.downloading addObject:downloading];
    [self.completions addObject:completion];
    
    [downloadTask resume];
    
}


////停止下载队列中位于index的任务
//- (void)stopDownloadTaskAtIndex:(NSInteger)index {
//    NSURLSessionDownloadTask *downloadTask = [self.downloadTasks objectAtIndex:index];
//    
//    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//        
//        [self.resumeDatas addObject:resumeData];
//        
//    }];
//    
//    [self.downloadTasks removeObjectAtIndex:index];
//}
//
////停止所有下载任务
//- (void)stopAllDownloadTasks {
//    
//    for (NSInteger index = 0; index < self.downloadTasks.count; index ++) {
//        
//        NSLog(@"begin resuming");
//        
//        NSURLSessionDownloadTask *downloadTask = [self.downloadTasks objectAtIndex:index];
//        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//                
//                NSLog(@"doing");
//                
//                [self.resumeDatas addObject:resumeData];
//            
//        }];
//        
//        NSLog(@"end resuming");
//    }
//    
//    [self.downloadTasks removeAllObjects];
//    
//    NSLog(@"Stop all the tasks");
//}
//
////恢复下载队列中位于index的任务
//- (void)resumeDownloadTaskAtIndex:(NSInteger)index {
//    NSData *resumeData = [self.resumeDatas objectAtIndex:index];
//    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithResumeData:resumeData];
//    [downloadTask resume];
//    [self.downloadTasks addObject:downloadTask];
//    [self.resumeDatas removeObjectAtIndex:index];
//}
//
////恢复所有下载任务
//- (void)resumeAllDownloadTasks {
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:self.resumeFile]) {
//        id result = [NSKeyedUnarchiver unarchiveObjectWithFile:self.resumeFile];
//        if (result != nil) {
//            self.resumeDatas = (NSMutableArray *)result;
//            NSLog(@"resume data exists: %ld", self.resumeDatas.count);
//        } else {
//            NSLog(@"resume data do not exist");
//        }
//    } else {
//        NSLog(@"resume file do not exist");
//    }
//
//    for (NSInteger index = 0; index < self.resumeDatas.count; index ++) {
//        NSData *resumeData = [self.resumeDatas objectAtIndex:index];
//        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithResumeData:resumeData];
//        [downloadTask resume];
//        [self.downloadTasks addObject:downloadTask];
//    }
//    
//    
//    [self.resumeDatas removeAllObjects];
//}
//
////取消下载队列中位于index的任务
//- (void)cancelDownloadTaskAtIndex:(NSInteger)index {
//    NSURLSessionDownloadTask *downloadTask = [self.downloadTasks objectAtIndex:index];
//    [downloadTask cancel];
//    [self.downloadTasks removeObjectAtIndex:index];
//}

//取消所有下载任务
- (void)cancelAllDownloadTasks {
    for (NSInteger index = 0; index < self.downloadTasks.count; index ++) {
        NSURLSessionDownloadTask *downloadTask = [self.downloadTasks objectAtIndex:index];
        [downloadTask cancel];
    }
    [self.downloadTasks removeAllObjects];
    [self.downloading removeAllObjects];
    [self.completions removeAllObjects];
    [self.files removeAllObjects];
}

////App退出时，若有尚未完成的下载任务，一律保存至下载重启应用时恢复下载
//- (void)saveAllDownloadTasksWhenAppTerminate {
//    
//    //若无下载任务且无暂停任务直接退出
//    if (self.downloadTasks.count == 0 && self.resumeDatas.count == 0) {
//        NSLog(@"无下载任务，直接退出保存工作");
//        return;
//    }
//    
//    NSLog(@"剩余任务数: %ld", self.downloadTasks.count);
//    
//    //存在未停止任务，停止所有正在进行的任务
//    if (self.downloadTasks.count != 0) {
//        [self stopAllDownloadTasks];
//    }
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:self.resumeFile]) {
//        NSLog(@"缓存文件已存在");
//        if ([[NSFileManager defaultManager] removeItemAtPath:self.resumeFile error:NULL]) {
//            NSLog(@"删除缓存文件成功");
//        }
//    }
//    
//    if ([NSKeyedArchiver archiveRootObject:self.resumeDatas toFile:self.resumeFile]) {
//        NSLog(@"写入成功暂停下载缓存文件成功");
//    } else {
//        NSLog(@"写入成功暂停下载缓存文件失败");
//    }
//}
//
////当前下载任务总数
//- (NSInteger)downloadTasksCount {
//    return self.downloadTasks.count;
//}
//
////当前停止的任务总数
//- (NSInteger)resumeDwonloadTasksCount {
//    return self.resumeDatas.count;
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"with error: %@", error);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
}



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSInteger index = [self.downloadTasks indexOfObject:downloadTask];
    
    ZWFile *file = [self.files objectAtIndex:index];
    
    NSString *fileName = file.name;
    
    NSString *destination = [[ZWUtilsCenter downloadDirectory] stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //若文件名字冲突则处理文件名
    
    NSInteger prefix = 1;
    NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    //文件名 不包含后缀
    NSString *filePreName = [fileName substringWithRange:NSMakeRange(0, range.location)];
    while ([fileManager fileExistsAtPath:destination]) {
        NSLog(@"文件名%@重复", fileName);
        fileName = [NSString stringWithFormat:@"%@(%ld).%@", filePreName, (long)prefix ++, file.type];
        NSLog(@"改为%@", fileName);
        destination = [[destination stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
    }
    
    
    
    if ([fileManager moveItemAtPath:[location path] toPath:destination error:& error]) {
        
        NSLog(@"移动 %@ 至 %@ 成功", [location lastPathComponent], [destination lastPathComponent]);
        
        [self.DBQueue inDatabase:^(FMDatabase *db) {
            
            //下载成功后保存下载信息至数据库
            if ([db open]) {
                //获取下载完成时的日期
                NSString *time = [NSDate current];
                
                NSString *insertSql1= [NSString stringWithFormat:
                                       @"INSERT INTO download_info (name, course, link, type, size, time) VALUES ('%@', '%@', '%@', '%@', '%@', '%@')", fileName, file.path, file.url, file.type, file.size, time];
                
                NSLog(@"url: %@", file.url);
                
                BOOL res = [db executeUpdate:insertSql1];
                
                if(res)  {
                    NSLog(@"保存下载信息成功");
                }  else  {
                    NSLog(@"保存下载信息失败");
                }
            }
            
        }];
        
    } else {
        if (error) {
           NSLog(@"移动 %@ 至 %@ 失败: %@", [location lastPathComponent], [destination lastPathComponent], error);
        }
    }
    
    NSLog(@"完成下载任务: %@", fileName);
    
    CompleteBlock completion = [self.completions objectAtIndex:index];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (completion) {
            completion(fileName);
        }
    });
    
    
    [self.files removeObjectAtIndex:index];
    
    [self.downloading removeObjectAtIndex:index];
    
    [self.completions removeObjectAtIndex:index];
    
    [self.downloadTasks removeObjectAtIndex:index];
    
    NSLog(@"剩余任务数: %ld", (unsigned long)self.downloadTasks.count);
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSInteger index = [self.downloadTasks indexOfObject:downloadTask];
    
    DownloadingBlock downloading = [self.downloading objectAtIndex:index];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloading) {
                downloading(totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
   
    
}

- (void)dealloc {
    NSLog(@"delloc");
}

@end

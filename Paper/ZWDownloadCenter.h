//
//  ZWDownloadCenter.h
//  Paper
//
//  Created by Administrator on 16/3/27.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDocumentModel.h"
#import "DataModels.h"

typedef void(^CompleteBlock)(NSString *fileName);
typedef void(^BeforeBlock)(void);
typedef void(^DownloadingBlock)(int64_t hasWritten, int64_t totalExpected);

typedef void(^Completion)(NSString *savedName);
typedef void(^Progress)(int64_t hasWritten, int64_t totalExpected);

@interface ZWDownloadCenter : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

//获取单例
+ (ZWDownloadCenter *)sharedDownloadCenter;

//- (void)startDownloadWithFile:(ZWFile *)file progress:(Progress)progress completion:(Completion)completion;


//添加任务
- (void)addDownloadTaskWithFile:(ZWFile *)file beforeDownload:(BeforeBlock)before whileDonwloading:(DownloadingBlock)downloading afterDownload:(CompleteBlock)completion;

////停止下载队列中位于index的任务
//- (void)stopDownloadTaskAtIndex:(NSInteger)index;
//
////停止所有下载任务
//- (void)stopAllDownloadTasks;
//
////恢复下载队列中位于index的任务
//- (void)resumeDownloadTaskAtIndex:(NSInteger)index;
//
////恢复所有下载任务
//- (void)resumeAllDownloadTasks;
//
////取消下载队列中位于index的任务
//- (void)cancelDownloadTaskAtIndex:(NSInteger)index;

//取消所有下载任务
- (void)cancelAllDownloadTasks;
//
////App退出时，若有尚未完成的下载任务，一律保存至下载重启应用时恢复下载
//- (void)saveAllDownloadTasksWhenAppTerminate;
//
////当前下载任务总数
//- (NSInteger)downloadTasksCount;
//
////当前停止的任务总数
//- (NSInteger)resumeDwonloadTasksCount;

@end

//
//  ZZPhotoPickerAlbumListVC.h
//  JSPhotoSDK
//
//  Created by 刘猛 on 2017/5/29.
//  Copyright © 2017年 刘猛. All rights reserved.
//
//  相册列表控制器
//

#import <UIKit/UIKit.h>
#import "ZZPhotoPickerVC.h"

@interface ZZPhotoPickerAlbumListVC : UIViewController
/**列数*/
@property (nonatomic , assign) NSInteger columnNumber;

@property(nonatomic ,copy) void(^selectedHandler)(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, ZZPhotoPickerSourceType sourceType,NSError *error);  // 数据回调

@property(nonatomic ,copy) void(^cancelHandler)(void);  // 取消选择的属性

@end

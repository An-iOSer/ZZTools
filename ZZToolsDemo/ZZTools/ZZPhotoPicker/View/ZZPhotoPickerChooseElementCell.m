//
//  ZZPhotoPickerChooseElementCell.m
//  JSPhotoSDK
//
//  Created by 刘猛 on 2017/6/2.
//  Copyright © 2017年 刘猛. All rights reserved.
//

#import "ZZPhotoPickerConst.h"
#import "IJSExtension.h"
#import "IJSExtension.h"
#import "ZZPhotoPickerAssetModel.h"
#import "ZZPhotoPickerImageManager.h"
#import "ZZPhotoPickerChooseElementCell.h"
#import "ZZPhotoPickerVC.h"
#import <IJSFoundation/IJSFoundation.h>

@interface ZZPhotoPickerChooseElementCell ()

/**左上角live标识*/
@property (nonatomic ,   weak) UIButton *livePhotoButton;
/**图片的唯一标识*/
@property (nonatomic , strong) NSString *representedAssetIdentifier;
/**视频*/
@property (nonatomic ,   weak) UIButton *videoButton;
/**背景图*/
@property (nonatomic ,   weak) UIImageView *contentImageView;
/**需要外部修改的右上角图片*/
@property (nonatomic ,   weak) UIButton *selectButton;
/**多选的蒙版*/
@property (nonatomic ,   weak) UIView *maskView;

@end

@implementation ZZPhotoPickerChooseElementCell

#pragma mark set方法
- (void)setModel:(ZZPhotoPickerAssetModel *)model {
    if (model == nil) {return;}
    
    _model = model;
    self.contentImageView.image = model.lastImage;
    [self.videoButton setTitle:model.timeLength forState:UIControlStateNormal];
    if (model.type != JSAssetModelMediaTypeLivePhoto) {
        self.livePhotoButton.hidden = YES;
    }
    
    self.representedAssetIdentifier = [[ZZPhotoPickerImageManager shareManager] getAssetIdentifier:model.asset]; //设置资源唯一标识
    __weak typeof(self) weakSelf = self;
    
    // 选择性加载图片裁剪的图片
    if (model.outputPath) {
        NSData *resultData = [NSData dataWithContentsOfURL:model.outputPath];
        UIImage *resultImage = [UIImage imageWithData:resultData];
        
        _contentImageView.image = resultImage;
    } else {
        if (model.imageRequestID) {[[PHImageManager defaultManager] cancelImageRequest:model.imageRequestID];}
        
        model.imageRequestID =  [[ZZPhotoPickerImageManager shareManager] getPhotoWithAsset:model.asset photoWidth:self.js_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if ([weakSelf.representedAssetIdentifier isEqualToString:[[ZZPhotoPickerImageManager shareManager] getAssetIdentifier:model.asset]]) {
                weakSelf.contentImageView.image = photo;
                model.lastImage = photo;
            } else {
                [[PHImageManager defaultManager] cancelImageRequest:model.imageRequestID];
            }
            if (!isDegraded) {
                model.imageRequestID = 0;
            }
        } progressHandler:nil networkAccessAllowed:NO];
        
    }
    // 改变button的状态
    //_select = model.isSelectedModel;
    _selectButton.selected = model.isSelectedModel;
    
    NSString *buttonTitle = [NSString stringWithFormat:@"%zd", model.cellButtonNnumber];
    if (model.cellButtonNnumber == 0) {
        buttonTitle = nil;
    }
    // 给button 加数据
    [_selectButton setTitle:model.isSelectedModel ? buttonTitle : nil forState:0];
    
    // 蒙版
    if (model.didMask && !_selectButton.selected) {
        self.maskView.hidden = NO;
        for (ZZPhotoPickerAssetModel *temp in model.didClickModelArr) {
            if (temp.onlyOneTag == model.onlyOneTag) {
                self.maskView.hidden = YES;
            }
        }
    } else {
        self.maskView.hidden = YES;
    }
    // 给模型的button加tag 用于回传数据使用
    _selectButton.tag = model.onlyOneTag;
}

- (void)setType:(JSAssetModelSourceType)type {
    _type = type;
    self.allowPickingGif = NO;
    self.contentImageView.hidden = NO;
    if (type == JSAssetModelMediaTypePhoto) {// image
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.selectButton.hidden = NO;
    } else if (type == JSAssetModelMediaTypeLivePhoto) { // LivePhoto
        self.selectButton.hidden = NO;
        self.videoButton.hidden = YES;
        self.livePhotoButton.hidden = NO;
    } else if (type == JSAssetModelMediaTypePhotoGif) { //Gif
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.selectButton.hidden = NO;
    } else {//  video
        self.selectButton.hidden = YES;
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = NO;
    }
}

/*-----------------------------------点击-------------------------------------------------------*/
#pragma mark 选择图片
- (void)selectPhotoButtonClick:(UIButton *)button {
    // 添加弹跳动画
    //[button addSpringAnimation];
    self.model.isSelectedModel = !self.model.isSelectedModel; //改变button的状态 刷新ui
    if ([self.cellDelegate respondsToSelector:@selector(didClickCellButtonWithButton:ButtonState:buttonIndex:)]) {
        [self.cellDelegate didClickCellButtonWithButton:button ButtonState:self.model.isSelectedModel buttonIndex:button.tag];
    }
}

- (void)seeLivePhoto:(UIButton *)button {
}

#pragma mark 懒加载区域
- (UIImageView *)contentImageView {
    if (_contentImageView == nil) {
        UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.js_width,self.js_height)];
        contentImageView.backgroundColor = [UIColor whiteColor];
        contentImageView.clipsToBounds = YES;
        contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:contentImageView];
        _contentImageView = contentImageView;
    }
    return _contentImageView;
}

- (UIButton *)selectButton {
    if (_selectButton == nil) {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(self.js_width - ButtonHeight, 0, ButtonHeight, ButtonHeight);
        [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_number_icon@2x" imageType:@"png"] forState:UIControlStateSelected];
        [selectButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectButton];
        _selectButton = selectButton;
    }
    return _selectButton;
}

- (UIButton *)livePhotoButton {
    if (_livePhotoButton == nil) {
        UIButton *livePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        livePhotoButton.frame = CGRectMake(2, 0, ButtonHeight, ButtonHeight);
        [livePhotoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"live@2x" imageType:@"png"] forState:UIControlStateNormal];
        [self.contentView addSubview:livePhotoButton];
        _livePhotoButton = livePhotoButton;
    }
    return _livePhotoButton;
}

- (UIButton *)videoButton {
    if (_videoButton == nil) {
        UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        videoButton.frame = CGRectMake(0, self.js_height - 10, self.js_width, 10);
        [videoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"VideoSendIcon@2x" imageType:@"png"] forState:UIControlStateNormal];
        [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        videoButton.titleLabel.font = [UIFont systemFontOfSize:12];
        videoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        videoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        videoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:videoButton];
        _videoButton = videoButton;
    }
    return _videoButton;
}

- (UIView *)maskView {
    if (_maskView == nil) {
        UIView *maskView = [[UIView alloc] initWithFrame:_contentImageView.frame];
        maskView.backgroundColor = [IJSFColor colorWithR:230 G:230 B:230 alpha:0.8];
        [self.contentView addSubview:maskView];
        _maskView = maskView;
        maskView.hidden = YES;
        [self bringSubviewToFront:maskView];
    }
    return _maskView;
}

@end


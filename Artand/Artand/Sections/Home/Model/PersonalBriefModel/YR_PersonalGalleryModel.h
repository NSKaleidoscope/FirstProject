//
//  YR_PersonalGalleryModel.h
//  Artand
//
//  Created by dllo on 16/09/12
//  Copyright (c) kaleidoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YR_PersonalGalleryListModel;

@interface YR_PersonalGalleryModel : NSObject

@property (nonatomic, strong) NSArray<YR_PersonalGalleryListModel *> *list;

@property (nonatomic, assign) NSInteger code;

@end
//
//  YR_SearchArtistModel.h
//  Artand
//
//  Created by dllo on 16/09/22
//  Copyright (c) kaleidoscope. All rights reserved.
//

#import "YR_BaseModel.h"

@class YR_SearchArtistListModel;

@interface YR_SearchArtistModel : YR_BaseModel

@property (nonatomic, strong) NSNumber *code;

@property (nonatomic, strong) NSArray<YR_SearchArtistListModel *> *list;

@property (nonatomic, copy) NSString *q;

@property (nonatomic, strong) NSNumber *last_id;

@end
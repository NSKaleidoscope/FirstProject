//
//  YR_ArtDetailViewController.h
//  Artand
//
//  Created by dllo on 16/9/1.
//  Copyright © 2016年 kaleidoscope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YR_ArtDetailViewController : UIViewController

@property (nonatomic, assign) CGFloat imageAspectRatio;
@property (nonatomic, strong) NSString *rowid;
@property (nonatomic, strong) UIImageView *fromImageView;

@property (nonatomic, assign) CGRect newRect;

@end

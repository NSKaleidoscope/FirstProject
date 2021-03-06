//
//  YR_LikeListViewController.m
//  Artand
//
//  Created by dllo on 16/9/1.
//  Copyright © 2016年 kaleidoscope. All rights reserved.
//

#import "YR_LikeListViewController.h"
#import "Masonry.h"
#import "YR_Macro.h"
#import "AFHTTPSessionManager.h"
#import "YR_EditorRecommendModel.h"
#import "YR_EditorRecommendTableViewCell.h"
#import "YR_EditorRecommendListModel.h"
#import "YR_EditorRecommendPicModel.h"
#import "UIButton+WebCache.h"
#import "YR_EditorRecommendUserModel.h"
#import "YR_TitleCollectionViewCell.h"
#import "UIView+Frame.h"
#import "YR_ArtDetailViewController.h"
#import "YR_ScrollView.h"
#import "YR_PersonalPageViewController.h"
#import "NSString+YR_TimeInterval.h"
#import "YR_RefreshGiHeaderTool.h"
#import "MJRefresh.h"

static NSString * const likeListCellReuse = @"likeListCellReuse";

@interface YR_LikeListViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, strong) UIView *naviView;
@property (nonatomic, strong) UICollectionView *titleCollectionView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) YR_ScrollView *backScrollView;
@property (nonatomic, strong) UIButton *popBtn;
@property (nonatomic, strong) UITableView *dayTableView;
@property (nonatomic, strong) UITableView *weekTableView;
@property (nonatomic, strong) UITableView *monthTableView;
@property (nonatomic, strong) YR_EditorRecommendModel *dayModel;
@property (nonatomic, strong) YR_EditorRecommendModel *weekModel;
@property (nonatomic, strong) YR_EditorRecommendModel *monthModel;

@property (nonatomic, strong) YR_RefreshGiHeaderTool *dayTableViewHeaderTool;
@property (nonatomic, strong) YR_RefreshGiHeaderTool *weekTableViewHeaderTool;
@property (nonatomic, strong) YR_RefreshGiHeaderTool *monthTableViewHeaderTool;

@end

@implementation YR_LikeListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self handleData];
    
    [self.backScrollView setContentOffset:CGPointMake(self.index * SCREEN_WIDTH, 0) animated:YES];
    [self collectionView:self.titleCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
}

- (void)handleData {
    
    self.manager = [AFHTTPSessionManager manager];
    // 日榜请求
    [_manager POST:@"http://ios1.artand.cn/discover/rank?type=today&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.dayModel = [YR_EditorRecommendModel modelWithDict:responseObject];
        [self.dayTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    // 周榜请求
    [_manager POST:@"http://ios1.artand.cn/discover/rank?type=week&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.weekModel = [YR_EditorRecommendModel modelWithDict:responseObject];
        [self.weekTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    // 月榜
    [_manager POST:@"http://ios1.artand.cn/discover/rank?type=month&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.monthModel = [YR_EditorRecommendModel modelWithDict:responseObject];
        [self.monthTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
    
    
}

- (void)setupUI {
    
    self.naviView = [[UIView alloc] init];
    self.naviView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.naviView];
    [self.naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(64);
    }];
    self.popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.naviView addSubview:self.popBtn];
    [self.popBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.width.height.mas_equalTo(44);
    }];
    [self.popBtn setImage:[UIImage imageNamed:@"pop"] forState:UIControlStateNormal];
    [self.popBtn addTarget:self action:@selector(popAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleArray = @[@"日榜", @"周榜", @"月榜"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (SCREEN_WIDTH - 88) / self.titleArray.count;
    CGFloat itemHeight = 44;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.titleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(44, 20, SCREEN_WIDTH - 88, 44) collectionViewLayout:layout];
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"YR_TitleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"reuse"];
    self.titleCollectionView.delegate = self;
    self.titleCollectionView.dataSource = self;
    self.titleCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleCollectionView];
    
    
    CGFloat width = 30;
    CGFloat height = 2;
    self.tintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tintView.centerX = (SCREEN_WIDTH - 88) / 6;
    self.tintView.centerY = self.titleCollectionView.height - 2.5;
    self.tintView.backgroundColor = [UIColor blackColor];
    [self.titleCollectionView addSubview:self.tintView];
    
    
    self.backScrollView = [[YR_ScrollView alloc] init];
    self.backScrollView.delegate = self;
    [self.view addSubview:self.backScrollView];
    [self.backScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.naviView.mas_bottom).offset(0);
    }];
    self.backScrollView.backgroundColor = [UIColor lightGrayColor];
    self.backScrollView.pagingEnabled = YES;
    self.backScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 0);
    //    [self.backScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(self.backScrollView.mas_left).mas_offset(0);
    //        make.width.mas_equalTo(SCREEN_WIDTH);
    //        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    //    }];
    
    self.dayTableView = [self createTableViewWithPointX:0];
    self.weekTableView = [self createTableViewWithPointX:SCREEN_WIDTH];
    self.monthTableView = [self createTableViewWithPointX:2 * SCREEN_WIDTH];
    
    self.dayTableViewHeaderTool = [[YR_RefreshGiHeaderTool alloc] initWithScrollView:self.dayTableView requestBlock:^{
        [_manager POST:@"http://ios1.artand.cn/discover/rank?type=today&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.dayModel = [YR_EditorRecommendModel modelWithDict:responseObject];
            [self.dayTableView reloadData];
            [self.dayTableView.mj_header endRefreshing];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }];
    
    self.weekTableViewHeaderTool = [[YR_RefreshGiHeaderTool alloc] initWithScrollView:self.weekTableView requestBlock:^{
        [_manager POST:@"http://ios1.artand.cn/discover/rank?type=week&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.weekModel = [YR_EditorRecommendModel modelWithDict:responseObject];
            [self.weekTableView reloadData];
            [self.weekTableView.mj_header endRefreshing];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }];
    
    self.monthTableViewHeaderTool = [[YR_RefreshGiHeaderTool alloc] initWithScrollView:self.monthTableView requestBlock:^{
        [_manager POST:@"http://ios1.artand.cn/discover/rank?type=month&last_id=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.monthModel = [YR_EditorRecommendModel modelWithDict:responseObject];
            [self.monthTableView reloadData];
            [self.monthTableView.mj_header endRefreshing];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
        
    }];
}

- (void)popAction:(UIButton *)btn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableView *)createTableViewWithPointX:(CGFloat)pointX {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(pointX, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"YR_EditorRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:likeListCellReuse];
    [self.backScrollView addSubview:tableView];
    return tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YR_EditorRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:likeListCellReuse];
    
    if (tableView == self.dayTableView) {        return [self cell:cell YR_EditorRecommendPicModeltransferCellDataWithModel:self.dayModel cellForRowAtIndexPath:indexPath];
    } else if (tableView == self.weekTableView) {
        return [self cell:cell YR_EditorRecommendPicModeltransferCellDataWithModel:self.weekModel cellForRowAtIndexPath:indexPath];
    } else {
        return [self cell:cell YR_EditorRecommendPicModeltransferCellDataWithModel:self.monthModel cellForRowAtIndexPath:indexPath];
    }
}
#pragma mark - 根据不同模型将数据传入同一个控制器
- (void)pushDetailViewControllerWithModel:(YR_EditorRecommendModel *)model indexPath:(NSIndexPath *)indexPath {
    
    YR_ArtDetailViewController *artDetailVC = [[YR_ArtDetailViewController alloc] init];
    NSString *rowid = model.list[indexPath.row].row_id;
    artDetailVC.rowid = rowid;
    artDetailVC.imageAspectRatio = [model.list[indexPath.row].pic.h floatValue] / [model.list[indexPath.row].pic.w floatValue];
    [artDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:artDetailVC animated:YES];
}
#pragma mark - 返回赋值完的cell
- (YR_EditorRecommendTableViewCell *)cell:(YR_EditorRecommendTableViewCell *)cell YR_EditorRecommendPicModeltransferCellDataWithModel:(YR_EditorRecommendModel *)model cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.btnBlock = ^{
        [self pushDetailViewControllerWithModel:model indexPath:indexPath];
    };
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *picStr = model.list[indexPath.row].pic.pid;
    NSString *fullStr = [NSString stringWithFormat:@"%@%@!app.c540.webp", @"http://work.artand.cn/", picStr];
    NSURL *picUrl = [NSURL URLWithString:fullStr];
    [cell.picBtn sd_setImageWithURL:picUrl forState:UIControlStateNormal];
    
    NSString *uidStr = model.list[indexPath.row].user.uid;
    NSString *versionStr = model.list[indexPath.row].user.version;
    NSString *iconStr = [[[@"http://head.artand.cn" stringByAppendingPathComponent:uidStr] stringByAppendingPathComponent:versionStr] stringByAppendingPathComponent:@"180"];
    [cell.iconBtn sd_setImageWithURL:[NSURL URLWithString:iconStr] forState:UIControlStateNormal];
    
    // 获取到更新的时间戳
    NSString *timeStr = model.list[indexPath.row].mtime;
    NSString *newStr = [timeStr updateTimeForTimeIntervalString:timeStr];
    cell.timeLabel.text = newStr;
    
    
    cell.imageNameLabel.text = model.list[indexPath.row].name;
    cell.artistNameLabel.text = model.list[indexPath.row].user.uname;
    cell.locationLabel.text = model.list[indexPath.row].user.city;
    
    NSString *likeStr = [NSString stringWithFormat:@"%@", model.list[indexPath.row].num_liked];
    [cell.likeBtn setTitle:likeStr forState:UIControlStateNormal];
    NSString *priceStr = model.list[indexPath.row].price;
    float price = [priceStr floatValue];
    if ([priceStr isEqualToString:@"0.00"]) {
        cell.priceView.hidden = YES;
    } else {
        cell.priceView.hidden = NO;
        if (price > 1000.0) {
            NSString *newPriceStr = [NSString stringWithFormat:@"¥%.2fK", price / 1000.0];
            cell.priceLabel.text = newPriceStr;
        } else {
            cell.priceLabel.text = priceStr;
        }
    }
    NSString *categoryStr = model.list[indexPath.row].category;
    NSString *sizeLabelStr = model.list[indexPath.row].size_label;
    NSString *timesStr = model.list[indexPath.row].times;
    NSString *descStr = [[categoryStr stringByAppendingPathComponent:sizeLabelStr] stringByAppendingPathComponent:timesStr];
    if ([priceStr isEqualToString:@"0.00"]) {
        cell.imageDesLabel.text = [descStr stringByAppendingPathComponent:@"非卖品"];
    } else {
        cell.imageDesLabel.text = descStr;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YR_PersonalPageViewController *personalPageVC = [[YR_PersonalPageViewController alloc] init];
    
    if (tableView == _dayTableView) {
        personalPageVC.uid = self.dayModel.list[indexPath.row].uid;
    } else if (tableView == _weekTableView) {
        personalPageVC.uid = self.weekModel.list[indexPath.row].uid;
    } else {
        personalPageVC.uid = self.monthModel.list[indexPath.row].uid;
    }
    
    [self.navigationController pushViewController:personalPageVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat titleLabelHeight = 77;
    return SCREEN_WIDTH + titleLabelHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    
    if (scrollView == self.backScrollView) {
        
        
        if (scrollView.contentOffset.x < 2 * SCREEN_WIDTH && scrollView.contentOffset.x > 0) {
            
            CGFloat cellWidth = (SCREEN_WIDTH - 88) / 3;
            self.tintView.centerX = cellWidth / 2 + self.backScrollView.contentOffset.x * cellWidth / SCREEN_WIDTH;
        }
        
        if (scrollView.contentOffset.x < 0) {
            scrollView.bounces = NO;
        }
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    
    NSInteger index = self.backScrollView.contentOffset.x / SCREEN_WIDTH;
    for (NSInteger i = 0; i < self.titleArray.count; i++) {
        if (i == index) {
            [self collectionView:self.titleCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        } else {
            [self collectionView:self.titleCollectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YR_TitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.titleLabel.textColor = [UIColor darkGrayColor];
    [self collectionView:self.titleCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat offsetX = indexPath.row * SCREEN_WIDTH;
    [self.backScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
    YR_TitleCollectionViewCell * cell = (YR_TitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:indexPath];
    [cell.titleLabel setTextColor:[UIColor blackColor]];
    for (NSInteger i = 0; i < self.titleArray.count; i++) {
        if (i != indexPath.row) {
            [self collectionView:self.titleCollectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YR_TitleCollectionViewCell * cell = (YR_TitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = [UIColor darkGrayColor];
}

@end

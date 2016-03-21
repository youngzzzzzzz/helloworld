//
//  MoreManageViewController.m
//  browser
//
//  Created by liguiyang on 14-6-19.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#define  TAG_PICMODEL_BUTTON 2222
#define  TAG_SIMPLEMODEL_BUTTON 2223
#define  TAG_ALERTVIEW_CLEARCACHE 2224

#import "MoreManageViewController.h"
#import "SDImageCache.h"
#import "MoreCell.h"
#import "SettingPlistConfig.h"
#import "SettingViewController_iphone.h" // 设置
#import "KyShared.h"
#import "MoreFeedbackViewController.h" // 意见反馈
#import "MoreAboutViewController.h" // 关于
#import "PopViewController.h" // 修复教程
#import "CustomNavigationBar.h"
#import "DownloadStatus.h"
#import "TMCache.h"
#import "DownLoadManageViewController.h"
#import "SelfSettingViewController.h" //自我设置
#import "RepairAppViewController.h" // 应用闪退修复
#import "LoginViewController.h"
#import "LoginSucessViewController.h"
#import "FreeAccountViewController.h"

#define MORE_CELL_COUNT 3


@interface MoreManageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat spaceEnd;
    UISwitch *downSwitch; // 仅Wi-Fi环境下载Switch
    UIButton *picModelBtn;
    UIButton *simpleModelBtn;
    UILabel *cacheLabel;
    UILabel *shareLabel;
    BOOL isCellLocked;
    MoreFeedbackViewController *moreFeedbackVC; // 意见反馈页面
    CustomNavigationBar *navTitleBar; // NavBar
    DownLoadManageViewController *downLoadVC;
    
}

@property (nonatomic, strong) NSString *cacheString;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MoreManageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self addObserver:self forKeyPath:@"cacheString" options:NSKeyValueObservingOptionNew context:nil];
        spaceEnd = IOS7?10.0f:15.0f;
    }
    return self;
}

#pragma mark - Initilization

#pragma mark - tableViewCell selected action

-(void)clearCacheAction:(id)sender
{  // 清理缓存
    UIAlertView *alert =[ [UIAlertView alloc]initWithTitle:@"是否要清理所有缓存数据？" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",@"否", nil];
    alert.tag = TAG_ALERTVIEW_CLEARCACHE;
    alert.delegate = self;
    [alert show];
}

-(void)shareAction:(id)sender
{ // 分享
    [KyShared shared].title = @"应用宝贝";
    [KyShared shared].description = WXContent;
    [KyShared shared].image = [UIImage imageNamed:@"more_logo.png"];
//    [KyShared shared].webpageUrl = [SINA_SHARE_URL stringByAppendingString:[DecryAppID getBundlePesudoAppID]];
    [KyShared shared].webpageUrl =WEIXIN_SHARE_URL;
    
    [KyShared shared].weiboText = WXContent;
    [KyShared shared].objectID = [DecryAppID getBundlePesudoAppID];
    [KyShared shared].showType = show_more;
    [[KyShared shared] show];
}

#pragma mark - Utility
- (void)clearCurrentCache{
    
    //清除缓存
    [[TMCache sharedCache] removeAllObjects];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    
    // 发现详情网页缓存清理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [cachePaths[0] stringByAppendingPathComponent:@"ASIHTTPRequestCache/SessionStore/"];
    [fileManager removeItemAtPath:cacheDir error:nil];
    [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:NULL];
}

-(void)hideClearCacheAnimation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingViewIsHide" object:@{@"bool":@"yes"}];
    cacheLabel.text = @"0.00MB";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"缓存清理完毕" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(NSString *)getCacheSize
{
    unsigned long long cacheFolderSize = 0;
    unsigned long long asiCacheSize = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [cachePaths[0] stringByAppendingPathComponent:@"ASIHTTPRequestCache/SessionStore/"];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:cacheDir];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:filePath error:nil];
        asiCacheSize += [fileDic fileSize];
    }
    
    // TMCache SDImageCache ASIHTTPCache(发现详情网页)
    cacheFolderSize = [TMCache sharedCache].diskCache.byteCount;
    CGFloat sdImageCount = [[SDImageCache sharedImageCache] getSize];
    CGFloat totalCacheCount = (cacheFolderSize + sdImageCount + asiCacheSize)/1024.0/1024.0;
    NSString *cacheSize = [NSString stringWithFormat:@"%.2lfMB",totalCacheCount];
    return cacheSize;
}

-(void)refreshCacheLabel
{
    // 子线程获取内存大小请勿删除，否则界面卡顿
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.cacheString = [self getCacheSize];
    });
}

-(void)scrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, 10) animated:NO];
}

-(void)selectRow:(NSIndexPath *)indexPath
{ // 接口
    [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
}

//-(void)pushDownloadViewController
//{
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    
//    DownLoadManageViewController *downLoadVC = [[DownLoadManageViewController alloc] init];
//    [downLoadVC showDownloadPage:@"downing"];
//    [self.navigationController pushViewController:downLoadVC animated:NO];
//}

-(void)setCustomFrame
{
    CGRect rect = self.view.frame;
    if (IOS7) {
        rect.size.height = self.view.frame.size.height - 12;
        self.tableView.frame = rect;
    }
    else
    {
        self.tableView.frame = CGRectMake(0, -15.0, rect.size.width, rect.size.height-50.0f);
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        cacheLabel.text = [change objectForKey:@"new"];
    });
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case TAG_ALERTVIEW_CLEARCACHE:{ // 清除缓存
            if (buttonIndex ==0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingViewIsHide" object:@{@"bool":@"no",@"content":@"缓存清理中..."}];
                [self performSelectorInBackground:@selector(clearCurrentCache) withObject:nil];
                [self performSelector:@selector(hideClearCacheAnimation) withObject:nil afterDelay:0.5f];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITabeleView datasource and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MORE_CELL_COUNT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //my助手调整
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                // 清除缓存
                static NSString *cellClearIden_more = @"clearCacheIden_more";
                MoreCell *clearCell_more = [tableView dequeueReusableCellWithIdentifier:cellClearIden_more];
                if (clearCell_more == nil) {
                    clearCell_more = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellClearIden_more];
                    //                    clearCell_more.headImgView.image = [UIImage imageNamed:@"more_clear.png"];
                    SET_IMAGE(clearCell_more.headImgView.image, @"more_clear.png");
                    clearCell_more.contentLabel.text = @"清除缓存";
                    
                    cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(clearCell_more.frame.size.width-spaceEnd-5-120, 7, 120, 30)];
                    cacheLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
                    cacheLabel.backgroundColor = [UIColor clearColor];
                    cacheLabel.textAlignment = NSTextAlignmentRight;
                    [clearCell_more addSubview:cacheLabel];
                }
                [self refreshCacheLabel];
                
                return clearCell_more;
            }
                break;
                
            case 1:{
                // 分享
                static NSString *cellShareIden_more = @"cellShareIdentifier_more";
                MoreCell *shareCell_more = [tableView dequeueReusableCellWithIdentifier:cellShareIden_more];
                if (shareCell_more == nil) {
                    shareCell_more = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellShareIden_more];
                    //                    shareCell_more.headImgView.image = [UIImage imageNamed:@"more_share.png"];
                    SET_IMAGE(shareCell_more.headImgView.image, @"more_share.png");
                    shareCell_more.contentLabel.text = @"分享";
                    
                    shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(shareCell_more.frame.size.width-spaceEnd-5-140, 7, 140, 30)];
                    shareLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
                    shareLabel.font = [UIFont systemFontOfSize:16.0];
                    shareLabel.textAlignment = NSTextAlignmentRight;
                    shareLabel.backgroundColor = [UIColor clearColor];
                    [shareCell_more addSubview:shareLabel];
                }
                
                NSDictionary *tmpDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"plist"]];
                NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
                NSString *version = [NSString stringWithFormat:@"V %@(%d)",localVersion, [[tmpDic objectForKey:@"build"] intValue]];
                shareLabel.text = version;
                
                return shareCell_more;
            }
                break;
                
            case 2:{
//                // 意见反馈
//                static NSString *cellFeedBackIden_more = @"cellFeedbackIdentifier_more";
//                MoreCell *feedbackCell_more = [tableView dequeueReusableCellWithIdentifier:cellFeedBackIden_more];
//                if (feedbackCell_more == nil) {
//                    feedbackCell_more = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFeedBackIden_more];
//                    //                    feedbackCell_more.headImgView.image = [UIImage imageNamed:@"more_feedback.png"];
//                    SET_IMAGE(feedbackCell_more.headImgView.image, @"more_feedback.png");
//                    feedbackCell_more.contentLabel.text = @"意见反馈";
//                    
//                    UIImageView *accessoryView = [[UIImageView alloc] init];
//                    SET_IMAGE(accessoryView.image, @"more_arrow.png");
//                    accessoryView.frame = CGRectMake(0, 0, 8.5, 16);
//                    feedbackCell_more.accessoryView = accessoryView;
//                }
//                return feedbackCell_more;
//            }
//                break;
//            case 3:{
                // 关于
                static NSString *cellAboutIden_more = @"cellAboutIdentifier_more";
                MoreCell *aboutCell_more = [tableView dequeueReusableCellWithIdentifier:cellAboutIden_more];
                if (aboutCell_more == nil) {
                    aboutCell_more = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellAboutIden_more];
                    //                    aboutCell_more.headImgView.image = [UIImage imageNamed:@"more-about.png"];
                    SET_IMAGE(aboutCell_more.headImgView.image, @"more-about.png");
                    aboutCell_more.contentLabel.text = @"关于";
                    [aboutCell_more hideCuttingLine:YES];
                    
                    UIImageView *accessoryView = [[UIImageView alloc] init];
                    SET_IMAGE(accessoryView.image, @"more_arrow.png");
                    accessoryView.frame = CGRectMake(0, 0, 8.5, 16);
                    aboutCell_more.accessoryView = accessoryView;
                    [aboutCell_more showHorizontalLine:bottomLine];
                }
                return aboutCell_more;
            }
                break;
                
            default:
                break;
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 32;
    }
    return 12;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isCellLocked) {
        return;
    }else{
        isCellLocked = YES;
        [self performSelector:@selector(unlockCell) withObject:nil afterDelay:0.3];
    }
    if (indexPath.section==0){
        switch (indexPath.row) {
            case 0:
            {
                // 清除缓存
                if (![cacheLabel.text isEqualToString:@"0.00MB"]) {
                    [self clearCacheAction:nil];
                }
            }
                break;
            case 1:
            {
                // 分享
                [self shareAction:nil];
            }
                break;
            case 2:
            {
//                // 意见反馈
//                [self.navigationController pushViewController:moreFeedbackVC animated:YES];
//            }
//                break;
//            case 3:
//            {
                // 关于
                MoreAboutViewController *moreAboutVC = [[MoreAboutViewController alloc] init];
                [self.navigationController pushViewController:moreAboutVC animated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:HIDETABBAR object:[NSNumber numberWithBool:YES]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)unlockCell{
    isCellLocked = NO;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // NavigationBar
    
    // TableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    [self.view addSubview:_tableView];
    
    [self setCustomFrame];
    
    // 下一级界面(意见反馈) 此处不释放防止二次进入反馈页崩溃
    moreFeedbackVC = [[MoreFeedbackViewController alloc] init];
    
    downLoadVC = [[DownLoadManageViewController alloc] init];
    [downLoadVC showDownloadPage:@"downing"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openlockappleidpage:) name:@"openlockappleidpage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCacheLabel) name:@"RefreshCacheSizeLabel" object:nil]; // 刷新缓存显示label
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    navTitleBar = [[CustomNavigationBar alloc] init];
    [navTitleBar showBackButton:NO navigationTitle:@"更多" rightButtonType:rightButtonType_NONE];
    // NavigationBar
    [self.navigationController.navigationBar addSubview:navTitleBar];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // NavigationBar
    [navTitleBar removeFromSuperview];
}

- (void)openlockappleidpage:(NSNotification*)note{
    NSDictionary *dic = [[FileUtil instance] getAccountPasswordInfo];
    if (dic && [dic objectForKey:SAVE_ACCOUNT] && [dic objectForKey:SAVE_PASSWORD]) {
        
        
        LoginSucessViewController*loginSucessViewController = [[LoginSucessViewController alloc]init];
        [self.navigationController pushViewController:loginSucessViewController animated:YES];
    }else{
        LoginViewController*loginViewController = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"cacheString" context:nil];
}

@end

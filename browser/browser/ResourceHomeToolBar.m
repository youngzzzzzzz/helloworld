//
//  ResourceHomeToolBar.m
//  MyAssistant
//
//  Created by liguiyang on 14-11-18.
//  Copyright (c) 2014年 myAssistant. All rights reserved.
//

#import "ResourceHomeToolBar.h"
#import "BppDistriPlistManager.h"

#define FIRST_BRODER 0//32/2
#define OTHER_BRODER 0//28/2
@interface ResourceHomeToolBar ()
{
    NSUInteger menuBtnCount;
}

@end

@implementation ResourceHomeToolBar

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        menuBtnCount = [Context defaults].homeToolBarBtnCount;
        
        // 精选
        self.choiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.choiceButton setImage:[self getTabBarImg:homeToolBar_ChoiceType selectFlag:NO] forState:UIControlStateNormal];
        [self.choiceButton setImage:[self getTabBarImg:homeToolBar_ChoiceType selectFlag:YES] forState:UIControlStateSelected];
        self.choiceButton.tag = homeToolBar_ChoiceType;
        
        // 游戏
        self.gameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.gameButton setImage:[self getTabBarImg:homeToolBar_GameType selectFlag:NO] forState:UIControlStateNormal];
        [self.gameButton setImage:[self getTabBarImg:homeToolBar_GameType selectFlag:YES] forState:UIControlStateSelected];
        self.gameButton.tag = homeToolBar_GameType;
        
        // 应用
        self.appButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.appButton setImage:[self getTabBarImg:homeToolBar_AppType selectFlag:NO] forState:UIControlStateNormal];
        [self.appButton setImage:[self getTabBarImg:homeToolBar_AppType selectFlag:YES] forState:UIControlStateSelected];
        self.appButton.tag = homeToolBar_AppType;
        
        // 搜索
        self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.searchButton setImage:[self getTabBarImg:homeToolBar_SearchType selectFlag:NO] forState:UIControlStateNormal];
        [self.searchButton setImage:[self getTabBarImg:homeToolBar_SearchType selectFlag:YES] forState:UIControlStateSelected];
        self.searchButton.tag = homeToolBar_SearchType;
        
        [self.choiceButton addTarget:self action:@selector(bottomBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.gameButton addTarget:self action:@selector(bottomBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.appButton addTarget:self action:@selector(bottomBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.searchButton addTarget:self action:@selector(bottomBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (menuBtnCount == 5) {
            // 我的
            self.mineButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.mineButton setImage:[self getTabBarImg:homeToolBar_MyType selectFlag:NO] forState:UIControlStateNormal];
            [self.mineButton setImage:[self getTabBarImg:homeToolBar_MyType selectFlag:YES] forState:UIControlStateSelected];
            [self.mineButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.mineButton.tag = homeToolBar_MyType;
            
            [self.mineButton addTarget:self action:@selector(bottomBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
//            downloadedBadge = [[DownloadedBadge alloc] init];
//            [self.mineButton addSubview:downloadedBadge];
//            [self.mineButton sendSubviewToBack:downloadedBadge];
            [self addSubview:_mineButton];
        }
        
        [self addSubview:_choiceButton];
        [self addSubview:_gameButton];
        [self addSubview:_appButton];
        [self addSubview:_searchButton];
        
        self.barTintColor = hllColor(51.0, 50.0, 51.0, 1.0);
        

        
        [self setSubviewsFrame];
        
    }
    
    return self;
}

-(void)bottomToolBarSelectItemType:(HomeToolBarItemType)itemType;
{ // 对外接口
    // 设置按钮 触发事件
    [self setBarButtonSelectedState:itemType];
    if (self.RHBardelegate && [self.RHBardelegate respondsToSelector:@selector(homeBottomToolBarItemClick:)]) {
        [self.RHBardelegate homeBottomToolBarItemClick:itemType];
    }
}

-(void)bottomBarButtonClick:(id)sender
{
    UIButton *barBtn = (UIButton *)sender;
    HomeToolBarItemType itemType_Selected = (HomeToolBarItemType)barBtn.tag;
    
    // 设置按钮状态
    [self setBarButtonSelectedState:itemType_Selected];
    // 触发事件
    if (self.RHBardelegate && [self.RHBardelegate respondsToSelector:@selector(homeBottomToolBarItemClick:)]) {
        [self.RHBardelegate homeBottomToolBarItemClick:itemType_Selected];
    }
}

-(void)setBarButtonSelectedState:(HomeToolBarItemType)itemSelectedType
{
    self.choiceButton.selected = (homeToolBar_ChoiceType == itemSelectedType)?YES:NO;
    self.appButton.selected = (homeToolBar_AppType == itemSelectedType)?YES:NO;
    self.gameButton.selected = (homeToolBar_GameType == itemSelectedType)?YES:NO;
    self.searchButton.selected = (homeToolBar_SearchType == itemSelectedType)?YES:NO;
    self.mineButton.selected = (homeToolBar_MyType==itemSelectedType)?YES:NO;
}

-(void)setSubviewsFrame
{
//    //    CGFloat scale = MainScreen_Width/320;
//    UIImage *oneImg = [self getTabBarImg:homeToolBar_ChoiceType selectFlag:NO];
//    CGFloat img_width = oneImg.size.width;
//    CGFloat space_interval = (MainScreen_Width-img_width*menuBtnCount)/(menuBtnCount+1);
//    
//    self.choiceButton.frame = CGRectMake(0, 0, img_width, BOTTOM_HEIGHT);
//    self.gameButton.frame = CGRectMake(img_width, 0, img_width, BOTTOM_HEIGHT);
//    self.appButton.frame = CGRectMake(img_width*2, 0, img_width, BOTTOM_HEIGHT);
//    self.searchButton.frame = CGRectMake(img_width*3, 0, img_width, BOTTOM_HEIGHT);
//    if (menuBtnCount == 5) {
//        self.mineButton.frame = CGRectMake(img_width*4, 0, img_width, BOTTOM_HEIGHT);
////        downloadedBadge.frame = CGRectMake(self.mineButton.frame.size.width*0.5+7, 2, 30, 20);
//    }
    float y = 0;
  
    float xishu = MainScreen_Width/320;
    self.choiceButton.frame = CGRectMake(FIRST_BRODER, y
                                    , BOTTOM_WIDTH*xishu, BOTTOM_HEIGHT);
    
    self.gameButton.frame = CGRectMake(self.choiceButton.frame.origin.x + self.choiceButton.frame.size.width , y, BOTTOM_WIDTH*xishu, BOTTOM_HEIGHT);
    
    self.appButton.frame = CGRectMake(self.gameButton.frame.origin.x + self.gameButton.frame.size.width - 1 , y, BOTTOM_WIDTH*xishu, BOTTOM_HEIGHT);
    
    self.searchButton.frame = CGRectMake(self.appButton.frame.origin.x + self.appButton.frame.size.width , y, BOTTOM_WIDTH*xishu, BOTTOM_HEIGHT);
    
    self.mineButton.frame = CGRectMake(self.searchButton.frame.origin.x + self.searchButton.frame.size.width-1, y, BOTTOM_WIDTH*xishu+2, BOTTOM_HEIGHT);
    
    
    
}

#pragma mark Utiltiy

- (UIImage *)getTabBarImg:(HomeToolBarItemType)itemType selectFlag:(BOOL)flag
{
    // head img name
    NSString *imgHeadStr = nil;
    switch (itemType) {
        case homeToolBar_ChoiceType:{
            imgHeadStr = flag?@"toolBar_choice_selected":@"toolBar_choice";
        }
            break;
        case homeToolBar_GameType:{
            imgHeadStr = flag?@"toolBar_game_selected":@"toolBar_game";
        }
            break;
        case homeToolBar_AppType:{
            imgHeadStr = flag?@"toolBar_app_selected":@"toolBar_app";
        }
            break;
        case homeToolBar_SearchType:{
            imgHeadStr = flag?@"toolBar_search_selected":@"toolBar_search";
        }
            break;
        case homeToolBar_MyType:{
            imgHeadStr = flag?@"toolBar_mine_selected":@"toolBar_mine";
        }
            break;
        default:
            break;
    }
    NSLog(@"分辨率W%f---H%f",[[UIScreen mainScreen] currentMode].size.width,[[UIScreen mainScreen] currentMode].size.height);
    // full img name
    NSString *imgName = nil;
    if (iPhone6) {
        imgName = [NSString stringWithFormat:@"%@6",imgHeadStr];
    }
    else if (iPhone5 || (iPhone4S || iPhone4))
    {
        imgName = [NSString stringWithFormat:@"%@",imgHeadStr];
    }
    else
    {
        imgName = [NSString stringWithFormat:@"%@6p",imgHeadStr];
    }
    
    if ([Context defaults].homeToolBarBtnCount == 5) {
        imgName = [imgName stringByAppendingString:@"_5.png"];
    }
    
    
    return [UIImage imageNamed:imgName];
}



@end

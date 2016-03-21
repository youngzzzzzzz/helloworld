//
//  SRRefreshView.m
//  SlimeRefresh
//
//  Created by admin on 12-6-15.
//  Copyright (c) 2012年 admin. All rights reserved.
//

#import "SRRefreshView.h"
#import "SRSlimeView.h"
#import "SRDefine.h"
#import <QuartzCore/QuartzCore.h>

@interface SRRefreshView()

@end

#define placeY 150 //调整位置
#define endDeceleratingtop 20
#define slimeAlpha 0.5

@implementation SRRefreshView {
    UIActivityIndicatorView *_activityIndicatorView;
    CGFloat     _oldLength;
    BOOL        _unmissSlime;
    CGFloat     _dragingHeight;
}

- (void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithHeight:32];
    return self;
}

- (id)initWithHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(0, 0, TheScreen_Width, height);
    self = [super initWithFrame:frame];
    if (self) {
        _slime = [[SRSlimeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _slime.startPoint = CGPointMake(frame.size.width/2, height/2);
        _slime.alpha = slimeAlpha;
        [self addSubview:_slime];
        
        _refleshView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sr_refresh"]];
        _refleshView.center = _slime.startPoint;
        _refleshView.bounds = CGRectMake(0.0f, 0.0f, kRefreshImageWidth, kRefreshImageWidth);
        [self addSubview:_refleshView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView stopAnimating];
        _activityIndicatorView.center = _slime.startPoint;
        [self addSubview:_activityIndicatorView];
        
        [_slime setPullApartTarget:self action:@selector(pullApart:)];
        _dragingHeight = height;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    if (_slime.state == SRSlimeStateNormal) {
        _slime.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        _slime.startPoint = CGPointMake(frame.size.width / 2, _dragingHeight / 2);
    }
    _refleshView.center = _activityIndicatorView.center = _slime.startPoint;
}

#pragma mark - setters

- (void)setUpInset:(CGFloat)upInset
{
    _upInset = upInset;
    UIEdgeInsets inset = _scrollView.contentInset;
    inset.top = _upInset;
    _scrollView.contentInset = inset;
    
}

- (void)setSlimeMissWhenGoingBack:(BOOL)slimeMissWhenGoingBack
{
    _slimeMissWhenGoingBack = slimeMissWhenGoingBack;
    if (!slimeMissWhenGoingBack) {
        _slime.alpha = slimeAlpha;
    }else {
        CGPoint p = _scrollView.contentOffset;
        self.alpha = -(p.y + _upInset) / _dragingHeight;
    }
}

- (void)setLoading:(BOOL)loading
{
    if (_loading == loading) {
        return;
    }
    _loading = loading;
    if (_loading) {
        [_activityIndicatorView startAnimating];
        
        //菊花大小变化
        //        CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        //
        //        aniamtion.values = [NSArray arrayWithObjects:
        //                            [NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DMakeScale(0.01, 0.01, 0.1),-M_PI, 0, 0, 1)],
        //                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)],
        //                            [NSValue valueWithCATransform3D:CATransform3DIdentity],nil];
        //        aniamtion.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:1], nil];
        //        aniamtion.timingFunctions = [NSArray arrayWithObjects:
        //                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        //                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], nil];
        //        aniamtion.duration = 0.3f;
        //        _activityIndicatorView.layer.transform = CATransform3DIdentity;
        //        [_activityIndicatorView.layer addAnimation:aniamtion forKey:@""];
        
        _slime.hidden = YES;//注释则渐变隐藏
        _refleshView.hidden = YES;
        if (!_scrollView.isDragging) {
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = _upInset+_dragingHeight;
            _scrollView.contentInset = inset;
        }
        if (!_unmissSlime){
            _slime.state = SRSlimeStateMiss;
        }else {
            _unmissSlime = NO;
        }
    }else {
        
        [_activityIndicatorView stopAnimating];
        _slime.hidden = NO;
        _refleshView.hidden = NO;
        _refleshView.layer.transform = CATransform3DIdentity;
        [UIView transitionWithView:_scrollView
                          duration:0.3f
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            UIEdgeInsets inset = _scrollView.contentInset;
                            inset.top = _upInset+endDeceleratingtop;
                            _scrollView.contentInset = inset;
                            if (_scrollView.contentOffset.y == -_upInset &&
                                _slimeMissWhenGoingBack) {
                                self.alpha = 0.0f;
                            }
                        } completion:^(BOOL finished) {
                            
                        }];
        
    }
}


- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (id)[self superview];
        CGRect rect = self.frame;
        rect.origin.y = rect.size.height?-rect.size.height:-_dragingHeight;
        rect.size.width = _scrollView.frame.size.width;
        self.frame = rect;
        self.slime.toPoint = self.slime.startPoint;
        
        UIEdgeInsets inset = _scrollView.contentInset;
        inset.top = _upInset;
        _scrollView.contentInset = inset;
    }else if (!self.superview) {
        _scrollView = nil;
    }
}

#pragma mark - action

- (void)pullApart:(SRRefreshView*)refreshView
{
    //拉断了
    _broken = YES;
    _unmissSlime = YES;
    self.loading = YES;
    if ([_delegate respondsToSelector:@selector(slimeRefreshStartRefresh:)]) {
        [(id)_delegate performSelector:@selector(slimeRefreshStartRefresh:) withObject:self afterDelay:0.0];
    }
    if (_block) {
        _block(self);
    }
}

- (void)scrollViewDidScroll
{
    CGPoint p = _scrollView.contentOffset;
    CGRect rect = self.frame;
    if (p.y <= - _dragingHeight - _upInset && !self.loading) {
        self.alpha = 1.0f;
        _slime.alpha = _refleshView.alpha = self.loading?0:slimeAlpha;
        rect.origin.y = p.y + _upInset-placeY;//调整位置
        rect.size.height = -p.y;
        rect.size.height = ceilf(rect.size.height);
        self.frame = rect;
        if (!self.loading) {
            [_slime setNeedsDisplay];
        }
        if (!_broken) {
            CGFloat l = -(p.y + _dragingHeight + _upInset);
            if (l <= _oldLength) {
                l = MIN(distansBetween(_slime.startPoint, _slime.toPoint), l);
                CGPoint ssp = _slime.startPoint;
                _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                CGFloat pf = (1.0f-l/_slime.viscous) * (1.0f-kStartTo) + kStartTo;
                _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }else if (_scrollView.isDragging) {
                CGPoint ssp = _slime.startPoint;
                _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                CGFloat pf = (1.0f-l/_slime.viscous) * (1.0f-kStartTo) + kStartTo;
                _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }
            _oldLength = l;
        }
    }else if (p.y < -_upInset) {
        _slime.alpha = _refleshView.alpha = 0;
        rect.origin.y = -_dragingHeight-placeY;//调整位置
        rect.size.height = _dragingHeight;
        self.frame = rect;
        [_slime setNeedsDisplay];
        _slime.toPoint = _slime.startPoint;
        if (_slimeMissWhenGoingBack) self.alpha = -(p.y + _upInset) / _dragingHeight;
    }
}

- (void)scrollViewDidEndDraging
{
    if (_broken) {
        if (self.loading) {
            [UIView transitionWithView:_scrollView
                              duration:0.3f
                               options:UIViewAnimationOptionCurveEaseOut
                            animations:^{
                                UIEdgeInsets inset = _scrollView.contentInset;
                                inset.top = _upInset+_dragingHeight+endDeceleratingtop;
                                _scrollView.contentInset = inset;
                            } completion:^(BOOL finished) {
                                _broken = NO;
                            }];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3f];
            [UIView commitAnimations];
        }else {
            [self performSelector:@selector(setBroken:) withObject:nil afterDelay:0];
            self.loading = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating
{
    _slime.alpha = _refleshView.alpha = 0;
}

- (void)endRefresh
{
    if (self.loading) {
        [self performSelector:@selector(restore) withObject:nil afterDelay:0];
    }
    _oldLength = 0;
}

- (void)restore
{
    _slime.toPoint = _slime.startPoint;
    
    //菊花大小变化
    //    [UIView transitionWithView:_activityIndicatorView
    //                      duration:0.3f
    //                       options:UIViewAnimationCurveEaseIn
    //                    animations:^{
    //                        _activityIndicatorView.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.01f, 0.01f, 0.1f), -M_PI, 0, 0, 1);
    //                    } completion:^(BOOL finished){
    //                        self.loading = NO;
    //                        _slime.state = SRSlimeStateNormal;
    //
    //                        _slime.alpha = _refleshView.alpha = 0;
    //
    //
    //                    }];
    
    self.loading = NO;
    _slime.state = SRSlimeStateNormal;
    _slime.alpha = _refleshView.alpha = 0;
    
}

@end

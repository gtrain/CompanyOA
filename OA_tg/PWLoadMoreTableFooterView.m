//
//  PWLoadMoreTableFooter.m
//  PWLoadMoreTableFooter
//
//  Created by Puttin Wong on 3/31/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//  上拉刷新

#import "PWLoadMoreTableFooterView.h"

@interface PWLoadMoreTableFooterView (Private)
- (void)setState:(PWLoadMoreState)aState;
@end

@implementation PWLoadMoreTableFooterView

@synthesize delegate=_delegate;

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		UILabel *label = nil;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		//label.font = [UIFont boldSystemFontOfSize:12.0f];
        label.font = [UIFont systemFontOfSize:13.0f];
        [label setAlpha:.8];
		//label.shadowColor = [UIColor colorWithWhite:0.9f alpha:.5f];
		//label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		//label.textAlignment = UITextAlignmentCenter;
        [label setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:label];
		_statusLabel=label;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(12, 12, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		[self setState:PWLoadMoreLoading];      //wait for the data source to tell me he has loaded all data
    }
	
    return self;
	
}

- (void)setState:(PWLoadMoreState)aState{
	
	switch (aState) {
		case PWLoadMoreNormal:
            [self addTarget:self action:@selector(callDelegateToLoadMore) forControlEvents:UIControlEventTouchUpInside];
            [self setEnabled:YES];
			_statusLabel.text = NSLocalizedString(@"点击加载更多", @"点击加载更多信息");
			[_activityView stopAnimating];
			break;
		case PWLoadMoreLoading:
            //[self removeTarget:self action:@selector(callDelegateToLoadMore) forControlEvents:UIControlEventTouchUpInside];
            [self setEnabled:NO];
			_statusLabel.text = NSLocalizedString(@"加载中...", @"加载信息中");
			[_activityView startAnimating];
			
			break;
		case PWLoadMoreDone:
            //[self removeTarget:self action:@selector(callDelegateToLoadMore) forControlEvents:UIControlEventTouchUpInside];
            [self setEnabled:NO];
			_statusLabel.text = NSLocalizedString(@"没有更多信息", @"没有更多信息...");
			[_activityView stopAnimating];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)pwLoadMoreTableDataSourceDidFinishedLoading {
    if ([self delegateIsAllLoaded]) {
        [self noMore];
    } else {
        [self canLoadMore];
    }
}

- (BOOL)delegateIsAllLoaded {
    BOOL _allLoaded = NO;
    if ([_delegate respondsToSelector:@selector(pwLoadMoreTableDataSourceAllLoaded)]) {
        _allLoaded = [_delegate pwLoadMoreTableDataSourceAllLoaded];
    }
    return _allLoaded;
}

- (void)resetLoadMore {
    if ([self delegateIsAllLoaded]) {
        [self noMore];
    } else
        [self canLoadMore];
}

- (void)canLoadMore {
    [self setState:PWLoadMoreNormal];
}

- (void)noMore {
    [self setState:PWLoadMoreDone];
}

- (void)realCallDelegateToLoadMore { //temporary
    if ([_delegate respondsToSelector:@selector(pwLoadMore)]) {
        [_delegate pwLoadMore];
        [self setState:PWLoadMoreLoading];
    }
}

-(void) updateStatus:(NSTimer *)timer{
    if ([_delegate respondsToSelector:@selector(pwLoadMoreTableDataSourceIsLoading)]) {
        if ([_delegate pwLoadMoreTableDataSourceIsLoading]) {
            //Do nothing
        } else {
            [timer invalidate];
            [self pwLoadMoreTableDataSourceDidFinishedLoading];
        }
    } else {
        //Do nothing
    }
}

- (void)callDelegateToLoadMore {
    if (_state == PWLoadMoreNormal) {
        if ([_delegate respondsToSelector:@selector(pwLoadMoreTableDataSourceIsLoading)]) {
            if ([_delegate pwLoadMoreTableDataSourceIsLoading]) {
                [self removeTarget:self action:@selector(callDelegateToLoadMore) forControlEvents:UIControlEventTouchUpInside];
                _statusLabel.text = NSLocalizedString(@"请求正在加载中...", @"等待其他请求完成");
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateStatus:) userInfo:nil repeats:YES];
            } else {
                [self realCallDelegateToLoadMore];
            }
        } else
            [self realCallDelegateToLoadMore];//temporary
    } else {
        //Do nothing
    }
}
#pragma mark -
#pragma mark Dealloc
- (void)dealloc {
	
	_delegate=nil;
    [super dealloc];
}
@end

//
//  SYPopupController.m
//  SYPopupController
//
//  Created by ahn soo yeol on 2016. 9. 20..
//  Copyright © 2016년 Ahns. All rights reserved.
//

#import "SYPopupController.h"
#import "MessagePopupCell.h"
#import "SelectPopupCell.h"

#define buttonDefaultTag 10
#define buttonsViewTopLineTag 123

#define HeaderHeight 25
#define DefaultSelectCellHeight 34
#define DefaultTopBarHeight 46
#define DefaultButtonsViewHeight 50
#define DefaultPopupRadius 8
#define ScreenBounds [UIScreen mainScreen].bounds
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SYPopupController ()<UITableViewDelegate, UITableViewDataSource> {
    BOOL isDismiss;
}

@property (nonatomic) id target;
@property (nonatomic) PopupMode mode;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) NSString *popupTitle;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSMutableArray *selectedData;
@property (weak, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) UIView *popupContainerView;
@property (weak, nonatomic) UIView *popupTitleBar;
@property (weak, nonatomic) UILabel *popupTitleLabel;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIView *popupButtonsView;
@property (weak, nonatomic) NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *buttonsViewHeightConstraint;

@end

@implementation SYPopupController

-(NSMutableArray *)selectedData {
    if(!_selectedData) {
        _selectedData = @[].mutableCopy;
    }
    return _selectedData;
}

#pragma mark - init

-(instancetype)initWithTarget:(id)target
                  withButtons:(NSArray *)buttons
                         mode:(PopupMode)mode
                    popupData:(id)popupData
                      options:(id)options
             actionComplition:(ActionComplition)actionComplition
{
    self = [super init];
    if(self) {
        _mode = mode;
        _target = target;
        _buttons = buttons;
        _popupTitle = popupData[kTitle];
        _message = popupData[kMessage];
        _listArray = popupData[kListData];
        _options = options;
        _actionComplition = actionComplition;
        
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+(SYPopupController *)showWithTarget:(id)target
                         withButtons:(NSArray *)buttons
                                mode:(PopupMode)mode
                           popupData:(id)popupData
                    actionComplition:(ActionComplition)actionComplition
{
    return [(SYPopupController *)[self alloc]initWithTarget:target
                                                withButtons:buttons
                                                       mode:mode
                                                  popupData:popupData
                                                    options:nil
                                           actionComplition:actionComplition];
}

+(SYPopupController *)showWithTarget:(id)target
                         withButtons:(NSArray *)buttons
                                mode:(PopupMode)mode
                           popupData:(id)popupData
                             options:(id)options
                    actionComplition:(ActionComplition)actionComplition
{
    return [(SYPopupController *)[self alloc]initWithTarget:target
                                                withButtons:buttons
                                                       mode:mode
                                                  popupData:popupData
                                                    options:options
                                           actionComplition:actionComplition];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self showWithTarget:self.target withButtons:self.buttons];
    
    [self.tableView registerClass:[MessagePopupCell class] forCellReuseIdentifier:NSStringFromClass([MessagePopupCell class])];
    [self.tableView registerClass:[SelectPopupCell class] forCellReuseIdentifier:NSStringFromClass([SelectPopupCell class])];
    
    if(![self.options[kBackgroundTapCloseOff] boolValue]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        [self.backgroundView addGestureRecognizer:tap];
    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setRoundRadius];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self buttonsSetting];
    
    if(!isDismiss)
    {
        CGFloat height = 0;
        if(self.mode == MessageMode) {
            CGFloat headerHeight = [self.options[kHeaderHeight] floatValue] ?: HeaderHeight;
            CGFloat footerHeight = [self.options[kFooterHeight] floatValue] ?: headerHeight;
            height = [self messageHeight] + (headerHeight + footerHeight);
        }else {
            height = ([self.options[kSelectCellHeight] integerValue] ?: DefaultSelectCellHeight) * self.listArray.count + HeaderHeight;
        }
        
        CGFloat virticalPadding = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? 72 : 20;
        CGFloat topHeight = [self.options[kTopBarHeight] integerValue] ?: DefaultTopBarHeight;
        CGFloat buttonHeight = [self.options[kButtonsViewHeight] integerValue] ?: DefaultButtonsViewHeight;
        CGFloat bottomHeight = [self.options[kVirticalButtons] boolValue] ? buttonHeight * self.buttons.count : buttonHeight;
        CGFloat maxHeight = CGRectGetHeight(ScreenBounds) - (topHeight + bottomHeight) - (virticalPadding*2);
        if(height > maxHeight) height = maxHeight;
        self.tableViewHeightConstraint.constant = height;
        self.buttonsViewHeightConstraint.constant = bottomHeight;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Popup Setup

-(void)setup
{
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = self.options[kPopupBackground] ?: [UIColor colorWithWhite:0.0f alpha:0.4f];
    
    UIView *containerView = [UIView new];
    containerView.clipsToBounds = YES;
    
    UIView *titleBar = [UIView new];
    titleBar.backgroundColor = self.options[kTopBarBackgroundColor] ?: UIColorFromRGB(0x87cc3e);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *buttonsView = [UIView new];
    buttonsView.backgroundColor = self.options[kButtonsViewBackgroundColor] ?: UIColorFromRGB(0xf1f1f1);
    
    UILabel *titleBarLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    
    NSString *defaultTitleString = self.mode == MessageMode ? @"알림" : @"선택하세요";
    titleBarLabel.text = self.popupTitle ?: defaultTitleString;
    titleBarLabel.font = self.options[kTopBarTextFont] ?: [UIFont boldSystemFontOfSize:16];
    titleBarLabel.textColor = self.options[kTopBarTextColor] ?: UIColorFromRGB(0x222222);
    [titleBarLabel sizeToFit];
    
    UIView *buttonsViewLine = [UIView new];
    buttonsViewLine.tag = buttonsViewTopLineTag;
    buttonsViewLine.backgroundColor = self.options[kButtonsViewLineColor] ?: UIColorFromRGB(0xe0e0e0);
    
    [self.view addSubview:backgroundView];
    [self.view addSubview:containerView];
    [containerView addSubview:titleBar];
    [containerView addSubview:tableView];
    [containerView addSubview:buttonsView];
    [titleBar addSubview:titleBarLabel];
    [buttonsView addSubview:buttonsViewLine];
    
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    titleBarLabel.translatesAutoresizingMaskIntoConstraints = NO;
    buttonsViewLine.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDics = NSDictionaryOfVariableBindings(backgroundView, containerView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[containerView]-20-|"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0]];
    
    viewDics = NSDictionaryOfVariableBindings(titleBar, tableView, buttonsView);
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleBar]|"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleBar]"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    [titleBar addConstraint:[NSLayoutConstraint constraintWithItem:titleBar
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:[self.options[kTopBarHeight] integerValue] ?: DefaultTopBarHeight]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleBar][tableView]"
                                                                      options:0 metrics:nil
                                                                        views:viewDics]];
    self.tableViewHeightConstraint = [NSLayoutConstraint constraintWithItem:tableView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:120];
    [tableView addConstraint:self.tableViewHeightConstraint];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buttonsView]|"
                                                                          options:0 metrics:nil
                                                                            views:viewDics]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView][buttonsView]|"
                                                                          options:0 metrics:nil
                                                                            views:viewDics]];
    self.buttonsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:buttonsView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0f
                                                                     constant:[self.options[kButtonsViewHeight] integerValue] ?: DefaultButtonsViewHeight];
    [buttonsView addConstraint:self.buttonsViewHeightConstraint];
    
    viewDics = NSDictionaryOfVariableBindings(buttonsViewLine);
    [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buttonsViewLine]|"
                                                                          options:0 metrics:nil
                                                                            views:viewDics]];
    [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonsViewLine(1)]"
                                                                          options:0 metrics:nil
                                                                            views:viewDics]];
    
    [titleBar addConstraint:[NSLayoutConstraint constraintWithItem:titleBarLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:titleBar
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    
    BOOL isTitleBottomY = [self.options[kTopBarTitleBottomY] boolValue];
    [titleBar addConstraint:[NSLayoutConstraint constraintWithItem:titleBarLabel
                                                         attribute:isTitleBottomY ? NSLayoutAttributeBottom : NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:titleBar
                                                         attribute:isTitleBottomY ? NSLayoutAttributeBottom : NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    
    self.backgroundView = backgroundView;
    self.popupContainerView = containerView;
    self.popupButtonsView = buttonsView;
    self.popupTitleBar = titleBar;
    self.popupTitleLabel = titleBarLabel;
    self.tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark - Set Round Radius

-(void)setRoundRadius
{
    self.popupContainerView.layer.cornerRadius = [self.options[kPopupRadius] integerValue] ?: DefaultPopupRadius;
}

#pragma mark - Bottom ButtonsView

-(void)buttonsSetting
{
    for(UIView *view in self.popupButtonsView.subviews) {
        if(view.tag != buttonsViewTopLineTag)
            [view removeFromSuperview];
    }
    
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat leadingAndTraillingPadding = 30;
    CGFloat buttonsViewWidth = CGRectGetWidth(screenBounds) - leadingAndTraillingPadding;
    CGFloat buttonHeight = [self.options[kButtonsViewHeight] integerValue] ?: DefaultButtonsViewHeight;
    
    BOOL isVirticalButton = [self.options[kVirticalButtons] boolValue];
    for(NSInteger i = 0; i < self.buttons.count; i++)
    {
        CGFloat buttonWidth = isVirticalButton ? buttonsViewWidth : buttonsViewWidth/self.buttons.count;
        NSString *buttonTitle = self.buttons[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = buttonDefaultTag + i;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitleColor:self.options[kButtonTextColor] ?: UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        button.titleLabel.font = self.options[kButtonTextFont] ?: [UIFont boldSystemFontOfSize:16];
        if(isVirticalButton)
            button.frame = CGRectMake(0, buttonHeight * i, buttonWidth, buttonHeight);
        else
            button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, buttonHeight);
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.popupButtonsView addSubview:button];
        
        if(self.buttons.count > 1 && i != self.buttons.count-1) {
            CGPoint buttonPoint = isVirticalButton ?  CGPointMake(0, CGRectGetMaxY(button.frame)) : CGPointMake(CGRectGetMaxX(button.frame), 0);
            CGSize buttonSize = isVirticalButton ? CGSizeMake(buttonWidth, 1) : CGSizeMake(1, buttonHeight);
            UILabel *line = [[UILabel alloc]initWithFrame: CGRectMake(buttonPoint.x, buttonPoint.y, buttonSize.width, buttonSize.height)];
            line.backgroundColor = self.options[kButtonsViewLineColor] ?: UIColorFromRGB(0xe0e0e0);
            [self.popupButtonsView addSubview:line];
        }
    }
}

-(void)buttonAction:(UIButton *)sender
{
    [self dismissSelectPopupWithAnimated:YES];
    
    if(self.actionComplition) self.actionComplition(sender.tag-buttonDefaultTag, self.selectedData);
}

#pragma mark - UITableView Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.mode == MessageMode)
        return 1;
    else
        return self.listArray.count;;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self.options[kHeaderHeight] floatValue] ?: HeaderHeight;
    return self.mode == MessageMode ? height : HeaderHeight/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [self.options[kHeaderHeight] floatValue] ?: HeaderHeight;
    height = [self.options[kFooterHeight] floatValue] ?: height;
    return self.mode == MessageMode ? height : HeaderHeight/2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), HeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), HeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.mode == MessageMode)
        return [self messageHeight];
    else
        return [self.options[kSelectCellHeight] integerValue] ?: DefaultSelectCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(self.mode == MessageMode)
    {
        MessagePopupCell *messageCell = [[MessagePopupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([MessagePopupCell class])];
        messageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(self.options[kMessageAttribute]) {
            messageCell.messageLabel.attributedText = self.options[kMessageAttribute];
        }else {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineSpacing = 10;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.message
                                                                                                attributes:@{NSFontAttributeName:self.options[kMessageTextFont] ?: [UIFont boldSystemFontOfSize:16],
                                                                                                             NSForegroundColorAttributeName:self.options[kMessageTextColor] ?: UIColorFromRGB(0x222222),
                                                                                                             NSParagraphStyleAttributeName:paragraphStyle}];
            messageCell.messageLabel.attributedText = attributedString;
        }
        cell = messageCell;
        
    }else
    {
        SelectPopupCell *selectCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelectPopupCell class]) forIndexPath:indexPath];
        
        NSString *title = self.listArray[indexPath.row];
        selectCell.titleLabel.text = title;
        
        BOOL isSelected = [self.selectedData containsObject:title];
        selectCell.checkBox.selected = isSelected;
        
        if(self.options[kSelectTextFont]) {
            selectCell.titleLabel.font = self.options[kSelectTextFont];
        }
        if(self.options[kSelectTextColor]) {
            selectCell.titleLabel.textColor = self.options[kSelectTextColor];
        }
        if(self.options[kCheckBoxImageNormal]) {
            [selectCell.checkBox setImage:self.options[kCheckBoxImageNormal] forState:UIControlStateNormal];
        }
        if(self.options[kCheckBoxImageSelected]) {
            [selectCell.checkBox setImage:self.options[kCheckBoxImageSelected] forState:UIControlStateNormal];
        }

        cell = selectCell;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.listArray[indexPath.row];
    if(self.mode == SelectItemMode) {
        [self.selectedData removeAllObjects];
        [self.selectedData addObject:text];
        
    }else if(self.mode == MultiSelectMode) {
        if([self.selectedData containsObject:text]) {
            [self.selectedData removeObject:text];
        }else {
            [self.selectedData addObject:text];
        }
    }
    [tableView reloadData];
}

-(CGFloat)messageHeight {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attribute = @{NSFontAttributeName:self.options[kMessageTextFont] ?: [UIFont boldSystemFontOfSize:16],
                                NSParagraphStyleAttributeName:paragraphStyle};
    if(self.options[kMessageAttribute]) {
        NSMutableAttributedString *aString = self.options[kMessageAttribute];
        attribute = [aString attributesAtIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, aString.length)];
    }
    
    CGFloat leadingAndTraillingPadding = 70;
    CGFloat width = CGRectGetWidth(ScreenBounds) - leadingAndTraillingPadding;
    CGSize sizeOfText = [self.message boundingRectWithSize:CGSizeMake(width, 9999)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                attributes:attribute
                                                   context:nil].size;
    return sizeOfText.height+1;
}

#pragma mark - Show

-(void)showWithTarget:(id)target withButtons:(NSArray *)buttons
{
    self.buttons = buttons;
    
    UIViewController *parent = (UIViewController *)target;
    [parent addChildViewController:self];
    self.view.frame = parent.view.bounds;
    [parent.view addSubview:self.view];
    [self didMoveToParentViewController:parent];
}

#pragma mark - Event Method

-(void)tapped:(UIGestureRecognizer *)recognizer
{
    [self dismissSelectPopupWithAnimated:YES];
}

-(void)dismissSelectPopup
{
    [self dismissSelectPopupWithAnimated:NO];
}

-(void)dismissSelectPopupWithAnimated:(BOOL)animated
{
    isDismiss = YES;
    
    if(animated)
    {
        [UIView animateWithDuration:1.0f animations:^{
            self.view.alpha = 0.0f;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
    {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

@end

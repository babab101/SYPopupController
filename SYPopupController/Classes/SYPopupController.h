//
//  SYPopupController.h
//  SYPopupController
//
//  Created by ahn soo yeol on 2016. 9. 20..
//  Copyright © 2016년 Ahns. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Popup Data Keys */
static NSString * const kTitle    = @"Title";
static NSString * const kMessage  = @"Message";
static NSString * const kListData = @"ListData";

/** Popup Option Keys */
static NSString * const kPopupBackground            = @"PopupBackground";
static NSString * const kVirticalButtons            = @"VirticalButtons";
static NSString * const kTopBarHeight               = @"TopBarHeight";
static NSString * const kTopBarBackgroundColor      = @"TopBarBackgroundColor";
static NSString * const kTopBarTextFont             = @"TopBarTextFont";
static NSString * const kTopBarTextColor            = @"TopBarTextColor";
static NSString * const kTopBarTitleBottomY         = @"TopBarTitleBottomY";
static NSString * const kTopBarTitleAttribute       = @"TopBarTitleAttribute";
static NSString * const kPopupRadius                = @"PopupRadius";
static NSString * const kHeaderHeight               = @"HeaderHeight";
static NSString * const kFooterHeight               = @"FooterHeight";
static NSString * const kMessageTextFont            = @"MessageTextFont";
static NSString * const kMessageTextColor           = @"MessageTextColor";
static NSString * const kMessageAttribute           = @"MessageAttribute";
static NSString * const kSelectCellHeight           = @"SelectCellHeight";
static NSString * const kSelectTextFont             = @"SelectTextFont";
static NSString * const kSelectTextColor            = @"SelectTextColor";
static NSString * const kCheckBoxImageNormal        = @"CheckBoxImageNormal";
static NSString * const kCheckBoxImageSelected      = @"CheckBoxImageSelected";
static NSString * const kButtonsViewHeight          = @"ButtonsViewHeight";
static NSString * const kButtonsViewBackgroundColor = @"ButtonsViewBackgroundColor";
static NSString * const kButtonsViewLineColor       = @"ButtonsViewLineColor";
static NSString * const kButtonTextFont             = @"ButtonTextFont";
static NSString * const kButtonTextColor            = @"ButtonTextColor";
static NSString * const kBackgroundTapCloseOff      = @"BackgroundTapCloseOff";

typedef NS_ENUM(NSInteger, PopupMode) {
    MessageMode,
    SelectItemMode,
    MultiSelectMode
};

typedef void (^ActionComplition)(NSInteger buttonIndex, id resultData);

@interface SYPopupController : UIViewController

@property (nonatomic, strong) ActionComplition actionComplition;

+(SYPopupController *)showWithTarget:(id)target
                         withButtons:(NSArray *)buttons
                                mode:(PopupMode)mode
                           popupData:(id)popupData
                    actionComplition:(ActionComplition)actionComplition;

+(SYPopupController *)showWithTarget:(id)target
                         withButtons:(NSArray *)buttons
                                mode:(PopupMode)mode
                           popupData:(id)popupData
                             options:(id)options
                    actionComplition:(ActionComplition)actionComplition;


@end

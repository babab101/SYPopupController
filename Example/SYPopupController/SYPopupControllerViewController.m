//
//  SYPopupControllerViewController.m
//  SYPopupController
//
//  Created by ahn soo yeol on 09/21/2016.
//  Copyright (c) 2016 ahn soo yeol. All rights reserved.
//

#import "SYPopupControllerViewController.h"
#import <SYPopupController/SYPopupController.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SYPopupControllerViewController ()

@property (nonatomic, strong) NSArray *demoArray;

@end

@implementation SYPopupControllerViewController

-(NSArray *)demoArray {
    if(!_demoArray) {
        _demoArray = @[@"MessagePopupMode",
                       @"SelectItemMode",
                       @"MultiSelectMode",
                       @"VirticalButtonPopup"];
    }
    return _demoArray;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([SYPopupController class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.demoArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PopupMode mode;
    NSDictionary *popupData;
    NSDictionary *options;
    NSArray *buttons;
    
    if(indexPath.row == 0) {
        NSString *title = @"알 림 설 정";
        NSString *message = @"바비톡 특별 이벤트 알림을 놓치지 마세요!\n바비톡 혜택 알림 수신을 통해 회원님께\n딱 맞는 이벤트 알림을 받으실 수 있습니다.";
        NSString *subMessage = @"\n\n( 바비톡 혜택 알림 수신은 ‘프로필 > 설정’에서 변경 )";
        NSString *tMessage = [message stringByAppendingString:subMessage];
        
        mode = MessageMode;
        popupData = @{kTitle:title,
                      kMessage:tMessage};
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 4;
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                     NSForegroundColorAttributeName:UIColorFromRGB(0x9696A8),
                                     NSParagraphStyleAttributeName:paragraphStyle};
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:tMessage
                                                                                            attributes:attributes];
        [attributeString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:13.0f]
                                range:NSMakeRange(tMessage.length - subMessage.length, subMessage.length)];
        
        buttons = @[@"알림 설정하고 혜택받기"];
        options = @{kPopupRadius:@6,
                    kHeaderHeight:@10,
                    kFooterHeight:@20,
                    kBackgroundTapCloseOff:@(YES),
                    kTopBarTitleBottomY:@(YES),
                    kTopBarTextFont:[UIFont boldSystemFontOfSize:18],
                    kTopBarTextColor:UIColorFromRGB(0x484760),
                    kTopBarBackgroundColor:[UIColor whiteColor],
                    kMessageAttribute:attributeString,
                    kButtonsViewHeight:@60,
                    kButtonsViewLineColor:[UIColor clearColor],
                    kButtonsViewBackgroundColor:UIColorFromRGB(0x897DFF),
                    kButtonTextColor:[UIColor whiteColor],
                    kButtonTextFont:[UIFont boldSystemFontOfSize:14.0f]};
        
    }else if(indexPath.row == 1) {
        
        mode = SelectItemMode;
        popupData = @{kTitle:@"자동차 선택",
                      kListData:@[@"QM6",@"쏘렌토",@"아반떼",@"말리부",@"SM6",@"티볼리",@"투싼",@"싼타페",@"e클래스"]};
        
        buttons = @[@"취소",@"완료"];
        options = @{kTopBarBackgroundColor:UIColorFromRGB(0xffd304)};
        
    }else if(indexPath.row == 2) {
        
        mode = MultiSelectMode;
        popupData = @{kTitle:@"사고 싶은 차 모두 고르세요",
                      kListData:@[@"QM6",@"쏘렌토",@"아반떼",@"말리부",@"SM6",@"티볼리",@"투싼",@"싼타페",@"e클래스"]};
        
        buttons = @[@"취소",@"선택 완료"];
        options = @{kSelectCellHeight:@44,
                    kSelectTextFont:[UIFont systemFontOfSize:18],
                    kButtonsViewBackgroundColor:[UIColor whiteColor],
                    kButtonTextColor:[UIColor brownColor],
                    kTopBarBackgroundColor:UIColorFromRGB(0xffa32e),
                    kPopupRadius:@2};
    }else {
        mode = MessageMode;
        popupData = @{kTitle:@"질문",
                      kMessage:@"다음 중 좋아하는 것은 무엇인가요?"};
        
        buttons = @[@"음악 감상",@"영화 보기",@"여행 하기"];
        options = @{kVirticalButtons:@(YES),
                    kTopBarHeight:@60,
                    kTopBarTextFont:[UIFont systemFontOfSize:30],
                    kTopBarTextColor:[UIColor whiteColor],
                    kTopBarBackgroundColor:[UIColor redColor]};
    }
    
    [SYPopupController showWithTarget:self.navigationController
                          withButtons:buttons
                                 mode:mode
                            popupData:popupData
                              options:options
                     actionComplition:^(NSInteger buttonIndex, id resultData) {
                         if(buttonIndex == 1) {
                             
                             NSString *text = @"";
                             for(NSString *string in resultData)
                             {
                                 NSString *addStr = [string stringByAppendingString:@" "];
                                 text = [text stringByAppendingString:addStr];
                             }
                             
                             text = text.length == 0 ? @"선택안함" : [text stringByAppendingString:@"선택"];
                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction *action = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:nil];
                             [alert addAction:action];
                             [self presentViewController:alert animated:YES completion:nil];
                         }
                     }];
}

@end

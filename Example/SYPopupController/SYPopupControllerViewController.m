//
//  SYPopupControllerViewController.m
//  SYPopupController
//
//  Created by ahn soo yeol on 09/21/2016.
//  Copyright (c) 2016 ahn soo yeol. All rights reserved.
//

#import "SYPopupControllerViewController.h"
#import <SYPopupController/SYPopupController.h>
#import <HexColors/HexColors.h>

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
        mode = MessageMode;
        popupData = @{kTitle:@"안내",
                      kMessage:@"결제 취소 가능 시간이 지났습니다.\n담당 교육기관에 문의 후\n취소하시기 바랍니다."};
        
        buttons = @[@"확인"];
        
    }else if(indexPath.row == 1) {
        
        mode = SelectItemMode;
        popupData = @{kTitle:@"자동차 선택",
                      kListData:@[@"QM6",@"쏘렌토",@"아반떼",@"말리부",@"SM6",@"티볼리",@"투싼",@"싼타페",@"e클래스"]};
        
        buttons = @[@"취소",@"완료"];
        options = @{kTopBarBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"ffd304"]};
        
    }else if(indexPath.row == 2) {
        
        mode = MultiSelectMode;
        popupData = @{kTitle:@"사고 싶은 차 모두 고르세요",
                      kListData:@[@"QM6",@"쏘렌토",@"아반떼",@"말리부",@"SM6",@"티볼리",@"투싼",@"싼타페",@"e클래스"]};
        
        buttons = @[@"취소",@"선택 완료"];
        options = @{kSelectCellHeight:@44,
                    kSelectTextFont:[UIFont systemFontOfSize:18],
                    kButtonsViewBackgroundColor:[UIColor whiteColor],
                    kButtonTextColor:[UIColor brownColor],
                    kTopBarBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"ffa32e"],
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

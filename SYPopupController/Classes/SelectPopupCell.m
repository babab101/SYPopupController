//
//  SelectPopupCell.m
//  SYPopupController
//
//  Created by ahn soo yeol on 2016. 9. 20..
//  Copyright © 2016년 Ahns. All rights reserved.
//

#import "SelectPopupCell.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation SelectPopupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBox.userInteractionEnabled = NO;
        UIImage *checkBoxNormalImage = [UIImage imageNamed:@"checkbox"];
        [checkBox setImage:checkBoxNormalImage forState:UIControlStateNormal];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateSelected];
        [checkBox sizeToFit];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = UIColorFromRGB(0x222222);
        
        [self.contentView addSubview:checkBox];
        [self.contentView addSubview:titleLabel];
        
        checkBox.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *viewDics = NSDictionaryOfVariableBindings(checkBox, titleLabel);
        NSDictionary *metrics = @{@"checkBoxImageWidth":@(checkBoxNormalImage.size.width)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[checkBox(checkBoxImageWidth)]-8-[titleLabel]-15-|"
                                                                                 options:0 metrics:metrics
                                                                                   views:viewDics]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:checkBox
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0f
                                                                      constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0f
                                                                      constant:0]];
        _checkBox = checkBox;
        _titleLabel = titleLabel;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

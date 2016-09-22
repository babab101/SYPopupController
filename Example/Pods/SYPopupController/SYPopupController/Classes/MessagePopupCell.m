//
//  MessagePopupCell.m
//  SYPopupController
//
//  Created by ahn soo yeol on 2016. 9. 20..
//  Copyright © 2016년 Ahns. All rights reserved.
//

#import "MessagePopupCell.h"

@implementation MessagePopupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        messageLabel.numberOfLines = 0;
        [self.contentView addSubview:messageLabel];
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *viewDics = NSDictionaryOfVariableBindings(messageLabel);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[messageLabel]-15-|"
                                                                                 options:0 metrics:nil
                                                                                   views:viewDics]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messageLabel]|"
                                                                                 options:0 metrics:nil
                                                                                   views:viewDics]];
        _messageLabel = messageLabel;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  JWEViewController.m
//  PlaceImage
//
//  Created by Jakub Wegrzyn on 06/06/14.
//  Copyright (c) 2014 Jakub Wegrzyn. All rights reserved.
//

#import "JWEViewController.h"

@interface JWEViewController ()

@property(nonatomic) NSUInteger counter;
@property(nonatomic) NSArray *colors;

@property(weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel *counterLabel;

@end

@implementation JWEViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.counter = 0;
    self.colors = @[
            [UIColor colorWithRed:51 / 255.0f green:77 / 255.0f blue:92 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:69 / 255.0f green:178 / 255.0f blue:157 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:239 / 255.0f green:201 / 255.0f blue:76 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:226 / 255.0f green:122 / 255.0f blue:63 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:223 / 255.0f green:73 / 255.0f blue:73 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:92 / 255.0f green:40 / 255.0f blue:73 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:167 / 255.0f green:62 / 255.0f blue:92 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:141 / 255.0f green:181 / 255.0f blue:0 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:0 / 255.0f green:133 / 255.0f blue:106 / 255.0f alpha:1.0f],
            [UIColor colorWithRed:166 / 255.0f green:136 / 255.0f blue:119 / 255.0f alpha:1.0f],
    ];

    [self updateDateTimeLabel];
    [self updateCounterLabel];

    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(updateDateTimeLabel)
                                   userInfo:nil
                                    repeats:YES];

    [self permutateColors];
    self.view.backgroundColor = self.colors[self.counter];
}

- (void)updateDateTimeLabel {
    NSAttributedString *dateTimeString = [self attributedStringFromDate:[NSDate date]];
    self.dateTimeLabel.attributedText = dateTimeString;
}

- (void)updateCounterLabel {
    NSDictionary *attributes = @{
            NSForegroundColorAttributeName : [UIColor whiteColor],
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0],
    };

    NSAttributedString *counterString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", self.counter + 1]
                                                                        attributes:attributes];
    self.counterLabel.attributedText = counterString;
}

- (IBAction)saveImage {
    UIColor *color = self.view.backgroundColor;
    NSAttributedString *primaryText = self.dateTimeLabel.attributedText;
    NSAttributedString *secondaryText = self.counterLabel.attributedText;

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize size = CGSizeMake(300, 300);
        UIImage *image = [self createImageWithSize:size
                                   backgroundColor:color
                                       primaryText:primaryText
                                     secondaryText:secondaryText];

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    });

    self.counter += 1;

    [self changeBackgroundColor];
    [self updateCounterLabel];
}

- (void)changeBackgroundColor {
    NSUInteger index = self.counter % self.colors.count;
    if (index == 0) {
        [self permutateColors];
    }

    self.view.backgroundColor = self.colors[index];
}

- (void)permutateColors {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.colors];
    NSUInteger count = [mutableArray count];
    if (count > 1) {
        for (NSUInteger i = count - 1; i > 0; --i) {
            [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t) (i + 1))];
        }
    }

    self.colors = [NSArray arrayWithArray:mutableArray];
}

- (NSAttributedString *)attributedStringFromDate:(NSDate *)date {
    NSAttributedString *dateString;
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        NSDictionary *attributes = @{
                NSForegroundColorAttributeName : [UIColor whiteColor],
                NSFontAttributeName : [UIFont boldSystemFontOfSize:18.0],
        };

        dateString = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:date]
                                                     attributes:attributes];
    }

    NSAttributedString *timeString;
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"'\n'HH:mm:ss";

        NSDictionary *attributes = @{
                NSForegroundColorAttributeName : [UIColor whiteColor],
                NSFontAttributeName : [UIFont boldSystemFontOfSize:24.0],
        };

        timeString = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:date]
                                                     attributes:attributes];
    }

    NSMutableAttributedString *dateTimeString = [[NSMutableAttributedString alloc] init];
    [dateTimeString appendAttributedString:dateString];
    [dateTimeString appendAttributedString:timeString];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];

    NSRange range = NSMakeRange(0, [dateTimeString length]);
    [dateTimeString addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:range];

    return dateTimeString;
}

- (UIImage *)createImageWithSize:(CGSize)size backgroundColor:(UIColor *)color primaryText:(NSAttributedString *)primaryText secondaryText:(NSAttributedString *)secondaryText {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    [color set];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));

    if (primaryText) {
        CGSize primaryTextSize = [primaryText size];
        CGRect primaryTextRect = CGRectMake(
                (size.width - primaryTextSize.width) / 2.0f,
                (size.height - primaryTextSize.height) / 2.0f,
                primaryTextSize.width,
                primaryTextSize.height
        );

        [primaryText drawInRect:primaryTextRect];
    }

    if (secondaryText) {
        const CGFloat margin = 10;
        CGSize secondaryTextSize = [secondaryText size];
        CGRect secondaryTextRect = CGRectMake(
                size.width - secondaryTextSize.width - margin,
                margin,
                secondaryTextSize.width,
                secondaryTextSize.height
        );

        [secondaryText drawInRect:secondaryTextRect];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end

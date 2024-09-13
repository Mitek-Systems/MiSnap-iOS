//
//  MobileFlowMrzResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 1/12/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileFlowMrzResult : NSObject

@property (nonatomic, assign, readonly) NSInteger confidence;
@property (nonatomic, strong, readonly) NSString *mrzString;
@property (nonatomic, strong, readonly) NSString *docNumber;
@property (nonatomic, strong, readonly) NSString *dob;
@property (nonatomic, strong, readonly) NSString *doe;
@property (nonatomic, strong, readonly) NSString *surname;
@property (nonatomic, strong, readonly) NSString *firstname;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *nationality;
@property (nonatomic, strong, readonly) NSString *sex;
@property (nonatomic, strong, readonly) NSString *personalNumber;
@property (nonatomic, strong, readonly) NSString *optionalNumber;
@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, strong, readonly) NSArray *personalNumberRects;

@end

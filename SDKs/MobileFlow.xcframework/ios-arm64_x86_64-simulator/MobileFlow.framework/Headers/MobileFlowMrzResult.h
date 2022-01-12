//
//  MobileFlowMrzResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 1/12/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end

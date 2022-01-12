//
//  MiSnapBarcodeScannerLight+NSString.m
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScannerLight+NSString.h"

@implementation NSString (MiSnapBarcodeScannerLight)

+ (NSString *)localizedBarcodeStringForKey:(NSString *)key
{
    return [[NSBundle mainBundle] localizedStringForKey:key value:key table:@"MiSnapBarcodeScannerLightLocalizable"];
}

@end

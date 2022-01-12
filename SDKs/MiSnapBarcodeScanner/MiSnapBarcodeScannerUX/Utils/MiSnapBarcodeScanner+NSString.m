//
//  MiSnapBarcodeScanner+NSString.m
//  MiSnapBarcodeScannerUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScanner+NSString.h"

@implementation NSString (MiSnapBarcodeScanner)

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [[NSBundle mainBundle] localizedStringForKey:key value:key table:@"MiSnapBarcodeScannerLocalizable"];
}

@end

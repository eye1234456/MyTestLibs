//
//  AAAConfig.m
//  AAASDK
//
//  Created by Flow on 4/26/22.
//

#import "AAAConfig.h"

@implementation AAAConfig
+ (void)sayHello {
    #ifdef DEBUG
            NSLog(@"AAAConfig debug");
            NSLog(@"domain: %@",URL_DOMAINS);
    #else
            NSLog(@"AAAConfig release");
            NSLog(@"domain: %@",URL_DOMAINS);
    #endif
}
@end

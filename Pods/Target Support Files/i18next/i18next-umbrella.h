#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "I18Next.h"
#import "I18NextCache.h"
#import "I18NextConnection.h"
#import "I18NextLoader.h"
#import "I18NextPlurals.h"
#import "NSObject+I18Next.h"
#import "NSString+I18Next.h"

FOUNDATION_EXPORT double i18nextVersionNumber;
FOUNDATION_EXPORT const unsigned char i18nextVersionString[];


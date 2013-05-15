#import <Foundation/Foundation.h>

@interface NSURL (StashParameters)

+ (NSDictionary *)dictionaryWithURLParametersFromString:(NSString *)urlString;

@end

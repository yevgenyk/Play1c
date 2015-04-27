#import "APLProduct.h"

@implementation APLProduct

+ (instancetype)productWithType:(NSString *)type name:(NSString *)name year:(NSNumber *)year price:(NSNumber *)price {
	APLProduct *newProduct = [[self alloc] init];
	newProduct.hardwareType = type;
	newProduct.title = name;
    newProduct.yearIntroduced = year;
    newProduct.introPrice = price;
    
	return newProduct;
}

+ (NSString *)deviceTypeTitle {
    return NSLocalizedString(@"Device", @"Device type title");
}
+ (NSString *)desktopTypeTitle {
    return NSLocalizedString(@"Desktop", @"Desktop type title");
}
+ (NSString *)portableTypeTitle {
    return NSLocalizedString(@"Portable", @"Portable type title");
}

+ (NSArray *)deviceTypeNames {
    static NSArray *deviceTypeNames = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        deviceTypeNames = @[[APLProduct deviceTypeTitle], [APLProduct portableTypeTitle], [APLProduct desktopTypeTitle]];
    });

    return deviceTypeNames;
}

+ (NSString *)displayNameForType:(NSString *)type {
    static NSMutableDictionary *deviceTypeDisplayNamesDictionary = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        deviceTypeDisplayNamesDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *deviceType in self.deviceTypeNames) {
            NSString *displayName = NSLocalizedString(deviceType, @"dynamic");
            deviceTypeDisplayNamesDictionary[deviceType] = displayName;
        }
    });

    return deviceTypeDisplayNamesDictionary[type];
}


#pragma mark - Encoding/Decoding

static NSString *NameKey = @"NameKey";
static NSString *TypeKey = @"TypeKey";
static NSString *YearKey = @"YearKey";
static NSString *PriceKey = @"PriceKey";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:NameKey];
        _hardwareType = [aDecoder decodeObjectForKey:TypeKey];
        _yearIntroduced = [aDecoder decodeObjectForKey:YearKey];
        _introPrice = [aDecoder decodeObjectForKey:PriceKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:NameKey];
    [aCoder encodeObject:self.hardwareType forKey:TypeKey];
    [aCoder encodeObject:self.yearIntroduced forKey:YearKey];
    [aCoder encodeObject:self.introPrice forKey:PriceKey];
}

@end

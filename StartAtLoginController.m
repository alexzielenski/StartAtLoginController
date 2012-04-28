// Copyright (c) 2011 Alex Zielenski
// Copyright (c) 2012 Travis Tilley
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense,  and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "StartAtLoginController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation StartAtLoginController

@synthesize identifier = _identifier;
@synthesize url        = _url;

#if !__has_feature(objc_arc)
- (void)dealloc {
    self.identifier = nil;
    self.url        = nil;
    [super dealloc];
}
#endif

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    
    if ([theKey isEqualToString:@"startAtLogin"]) {
        automatic = NO;
    } else if ([theKey isEqualToString:@"enabled"]) {
        automatic = NO;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    
    return automatic;
}

-(id)initWithBundle:(NSBundle*)bndl
{
    self = [super init];
    if (self) {
        _enabled = NO;
        [self setBundle:bndl];
        
        // this method call initializes _enabled to the correct value as a side effect.
        [self startAtLogin];
#if !defined(NDEBUG)
        NSLog(@"Launcher '%@' %@ configured to start at login",
              self.identifier, (_enabled ? @"is" : @"is not"));
#endif
    }
    return self;
}

- (void)setBundle:(NSBundle*)bndl {
    self.identifier = [bndl bundleIdentifier];
    self.url        = [bndl bundleURL];
}

- (BOOL)startAtLogin {
    if (!_identifier)
        return NO;
    
    BOOL isEnabled  = NO;
    
    // the easy and sane method (SMJobCopyDictionary) can pose problems when sandboxed. -_-
    CFArrayRef cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([_identifier isEqualToString:[job objectForKey:@"Label"]]) {
                isEnabled = [[job objectForKey:@"OnDemand"] boolValue];
                break;
            }
        }
    }
    
    if (isEnabled != _enabled) {
        [self willChangeValueForKey:@"enabled"];
        _enabled = isEnabled;
        [self didChangeValueForKey:@"enabled"];
    }
    
    return isEnabled;
}

- (void)setStartAtLogin:(BOOL)flag {
    if (!_identifier||!_url)
        return;
    
    [self willChangeValueForKey:@"startAtLogin"];
    
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)_identifier, (flag) ? true : false)) {
        NSLog(@"SMLoginItemSetEnabled failed!");
        
        [self willChangeValueForKey:@"enabled"];
        _enabled = NO;
        [self didChangeValueForKey:@"enabled"];
    } else {
        [self willChangeValueForKey:@"enabled"];
        _enabled = YES;
        [self didChangeValueForKey:@"enabled"];
    }
    
    [self didChangeValueForKey:@"startAtLogin"];
}

- (BOOL)enabled
{
    return _enabled;
}

- (void)setEnabled:(BOOL)enabled
{
    [self setStartAtLogin:enabled];
}

@end

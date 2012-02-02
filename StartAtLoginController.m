// Copyright (c) 2011 Alex Zielenski
// All Rights Reserved
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
@dynamic startAtLogin;

#if !__has_feature(objc_arc)
- (void)dealloc {
	self.identifier = nil;
	self.url        = nil;
	[super dealloc];
}
#endif

- (void)setBundle:(NSBundle*)bndl {
	self.identifier = [bndl bundleIdentifier];
	self.url        = [bndl bundleURL];
}

- (BOOL)startAtLogin {
	if (!_identifier)
		return NO;
    
    CFDictionaryRef cfdict = SMJobCopyDictionary(kSMDomainUserLaunchd, (__bridge CFStringRef)_identifier);
	NSDictionary *dict = (NSDictionary*)CFBridgingRelease(cfdict);
	BOOL contains = (dict!=NULL);
	return contains;
}

- (void)setStartAtLogin:(BOOL)flag {
	if (!_identifier||!_url)
		return;
	[self willChangeValueForKey:@"startAtLogin"];
	// Let ServiceManagement know that we exist
	if (LSRegisterURL((__bridge CFURLRef)_url, true) != noErr) {
		NSLog(@"LSRegisterURL failed!");
	}

	// Make the setting
	if (!SMLoginItemSetEnabled((__bridge CFStringRef)_identifier, (flag) ? true : false)) {
		NSLog(@"SMLoginItemSetEnabled failed!");
	}
	[self didChangeValueForKey:@"startAtLogin"];
}

- (void)remove {
	if (!_identifier)
		return;
	[self willChangeValueForKey:@"startAtLogin"];
	CFErrorRef error = NULL;
	if (!SMJobRemove(kSMDomainUserLaunchd, (__bridge CFStringRef)_identifier, NULL, true, &error)) {
		NSLog(@"Could not remove job entry: %@", (__bridge NSError*)error);
	}
	[self didChangeValueForKey:@"startAtLogin"];
}

@end
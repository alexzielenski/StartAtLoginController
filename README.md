# StartAtLoginController

Easy to use controller that makes uses of the new ServiceManagement APIs. This is the required way to do login items for sandboxed Applications and soon Apple will make sandboxing required for all Mac App Store Apps so you should update early! (Works in non-sandboxed applications as well)

I have tested it on 10.7 and it supports removing login dictionaries. Also, entries set by this class do not appear to be showing up in the Accounts Panel of System Preferences.

## HOW-TO

You must create an instance of the controller and set the bundle for it to use to your helper bundle. (It must point to a helper bundle that has LSBackgroundOnly or LSUIElement set to YES in its Info.plist and put this bundle in Contents/Library/LoginItems). 

Here is an example of a helper bundle:

	- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
	{
		NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]; 
		// get to the waaay top. Goes through LoginItems, Library, Contents, Applications
		[[NSWorkspace sharedWorkspace] launchApplication:appPath];
		[NSApp terminate:nil];
	}
	
Then in your application you can set the bundle (identifier/path) of your helper app:

	StartAtLoginController loginController = [[StartAtLoginController alloc] init];
	[loginController setBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/AppHelper.app"]]];
	
And now you can manipulate the Services Entry:

	[loginController setStartAtLogin: YES]; // adds the entry into LaunchServices and activates it
	//
	//
	[loginController remove]; // removes the entire entry from the services list
	//
	//
	BOOL startsAtLogin = [loginController startAtLogin]; // gets the current enabled state
	
Unfortunately you cannot use interface builder to bind your checkbox to this object since you need to set the bundle of your helper app. But you can make a property accessor for you helper app in your prefs controller and bind it through there.

## REQUIREMENTS

Works only on 10.6.6 and up

## LICENSE

This is licensed under MIT. Here is some legal jargon:

Copyright (c) 2011 Alex Zielenski
All Rights Reserved

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
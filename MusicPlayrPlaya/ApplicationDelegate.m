#import "ApplicationDelegate.h"

void *kContextActivePanel = &kContextActivePanel;

@implementation ApplicationDelegate

@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
    [_menubarController release];
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
    [_panelController release];
    
    [super dealloc];
}

- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel)
    {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
        
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                                 nil]];
    }
    
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    [self.menubarController = [[MenubarController alloc] init] release];
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
    
}

- (IBAction)toggleRightPanel:(id)sender{
    NSLog(@"CLICK DIREITO");
    [self.panelController openMenu];
    self.panelController.close;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil)
    {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:NSKeyValueObservingOptionInitial context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}


-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	//int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				[self.panelController.webview stringByEvaluatingJavaScriptFromString:@"player.state ==='player_state_paused' ? player.play() : player.pause();"];
				break;
				
			case NX_KEYTYPE_FAST:
				[self.panelController.webview stringByEvaluatingJavaScriptFromString:@"$('.jp-next').click();"];
				break;
				
			case NX_KEYTYPE_REWIND:
				[self.panelController.webview stringByEvaluatingJavaScriptFromString:@"$('.jp-previous').click();"];
				break;
			default:
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
		
	}
}

@end


#import "MenubarController.h"
#import "PanelController.h"
#import "SPMediaKeyTap.h"


@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate> {
@private
    MenubarController *_menubarController;
    PanelController *_panelController;
    SPMediaKeyTap *keyTap;
    
}

@property (nonatomic, retain) MenubarController *menubarController;
@property (nonatomic, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;
- (IBAction)toggleRightPanel:(id)sender;
@end

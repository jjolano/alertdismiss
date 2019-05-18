#include <UIKit/UIKit.h>

%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	if([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
		// Handle UIAlertController
		UIAlertController *alert = (UIAlertController *)viewControllerToPresent;

		#ifdef DEBUG
		NSLog(@"[alertdismiss] presenting UIAlertController");
		#endif

		// Check if this alert controller has any actions.
		if([[alert actions] count] == 0) {
			// Add a dismiss button.
			UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
			[alert addAction:defaultAction];

			#ifdef DEBUG
			NSLog(@"[alertdismiss] added OK action");
			#endif
		}
	}

	%orig;
}
%end

%ctor {
	%init;
}

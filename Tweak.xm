#include <UIKit/UIKit.h>

%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	if([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
		// Handle UIAlertController
		UIAlertController *alert = (UIAlertController *)viewControllerToPresent;

		#ifdef DEBUG
		NSLog(@"[alertdismiss] presenting UIAlertController");
		#endif

		// Add a dismiss button.
		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Force Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
		[alert addAction:defaultAction];

		#ifdef DEBUG
		NSLog(@"[alertdismiss] added dismiss action");
		#endif
	}

	%orig;
}
%end

%ctor {
	%init;
}

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>

BOOL prefs_only_actionless = NO;
BOOL prefs_dismiss_alerts = YES;
BOOL prefs_dismiss_actionsheets = YES;

%group deprecated_actionsheets
%hook UIActionSheet
- (void)showFromTabBar:(UITabBar *)view {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}

- (void)showFromToolbar:(UIToolbar *)view {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}

- (void)showInView:(UIView *)view {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}
%end
%end

%group deprecated_alerts
%hook UIAlertView
- (void)show {
	BOOL force_dismiss = YES;

	if(prefs_only_actionless && [self numberOfButtons] != 0) {
		force_dismiss = NO;
	}

	if(force_dismiss) {
		[self addButtonWithTitle:@"Force Dismiss"];
	}

	%orig;
}
%end
%end

%group current
%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	if([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
		// Handle UIAlertController
		UIAlertController *alert = (UIAlertController *)viewControllerToPresent;

		BOOL force_dismiss = NO;

		if(prefs_dismiss_alerts && [alert preferredStyle] == UIAlertControllerStyleAlert) {
			force_dismiss = YES;
		}

		if(prefs_dismiss_actionsheets && [alert preferredStyle] == UIAlertControllerStyleActionSheet) {
			force_dismiss = YES;
		}

		if(prefs_only_actionless && [[alert actions] count] != 0) {
			force_dismiss = NO;
		}

		if(force_dismiss) {
			// Add a dismiss button.
			UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Force Dismiss" style:UIAlertActionStyleDefault handler:nil];
			[alert addAction:defaultAction];
		}
	}

	%orig;
}
%end
%end

%ctor {
	BOOL prefs_tweak_enabled = YES;

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.jjolano.alertdismiss.plist"];

	if(prefs) {
		if(prefs[@"tweak_enabled"]) {
			prefs_tweak_enabled = [prefs[@"tweak_enabled"] boolValue];
		}

		if(prefs[@"only_actionless"]) {
			prefs_only_actionless = [prefs[@"only_actionless"] boolValue];
		}

		if(prefs[@"dismiss_alerts"]) {
			prefs_dismiss_alerts = [prefs[@"dismiss_alerts"] boolValue];
		}

		if(prefs[@"dismiss_actionsheets"]) {
			prefs_dismiss_actionsheets = [prefs[@"dismiss_actionsheets"] boolValue];
		}
	}

	if(prefs_tweak_enabled && (prefs_dismiss_alerts || prefs_dismiss_actionsheets)) {
		if(kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_9_0) {
			if(prefs_dismiss_actionsheets) {
				%init(deprecated_actionsheets);
			}

			if(prefs_dismiss_alerts) {
				%init(deprecated_alerts);
			}
		}

		if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
			%init(current);
		}
	}
}

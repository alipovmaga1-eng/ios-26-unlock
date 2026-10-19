#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Достаём view главного экрана (иконки) без жёсткой привязки к заголовкам SpringBoard
static UIView *Unlock26HomeView(void) {
    @try {
        id iconController = [objc_getClass("SBIconController") performSelector:@selector(sharedInstance)];
        id iconManager = [iconController valueForKey:@"iconManager"];
        id rootFolderController = [iconManager valueForKey:@"rootFolderController"];
        id view = [rootFolderController valueForKey:@"view"];
        return [view isKindOfClass:[UIView class]] ? view : nil;
    } @catch (NSException *e) {
        return nil;
    }
}

// Эффект iOS 26: главный экран "выплывает" из размытия с лёгким увеличением
static void Unlock26Play(void) {
    UIView *home = Unlock26HomeView();
    if (!home) return;

    // Стеклянная вуаль, которая растворяется
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
    glass.frame = home.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.userInteractionEnabled = NO;
    [home addSubview:glass];

    home.transform = CGAffineTransformMakeScale(0.90, 0.90);
    home.alpha = 0.35;

    [UIView animateWithDuration:0.65
                          delay:0.0
         usingSpringWithDamping:0.82
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        home.transform = CGAffineTransformIdentity;
        home.alpha = 1.0;
    } completion:nil];

    [UIView animateWithDuration:0.45
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        glass.alpha = 0.0;
    } completion:^(BOOL finished) {
        [glass removeFromSuperview];
    }];
}

%hook SBCoverSheetPrimarySlidingViewController

// presented == NO значит шторка (экран блокировки) уходит, т.е. телефон разблокирован
- (void)_finishTransitionToPresented:(BOOL)presented animated:(BOOL)animated withCompletion:(id)completion {
    if (!presented && animated) {
        Unlock26Play();
    }
    %orig;
}

%end

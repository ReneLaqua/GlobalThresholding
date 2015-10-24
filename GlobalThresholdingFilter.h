//
//  GlobalThresholdingFilter.h
//  GlobalThresholding
//
//  Copyright (c) 2012 Rene Laqua
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

@interface GlobalThresholdingFilter : PluginFilter {
    
    IBOutlet NSWindow		*window;
    IBOutlet NSTextField	*lowThreshold, *highThreshold, *thresholdROIname;
    IBOutlet NSButton		*chkLowThreshold, *chkHighThreshold;
    IBOutlet NSButtonCell	*btnCurSlice, *btnCurViewer;
    
}

- (long) filterImage:(NSString*) menuName;
- (IBAction) openWebsite:(id)sender;
- (IBAction) openEmail:(id)sender;
- (void) CreateBrushROI:(id) sender;

@end

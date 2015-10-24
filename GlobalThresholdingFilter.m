//
//  GlobalThresholdingFilter.m
//  GlobalThresholding
//
//  Copyright (c) 2012 Rene Laqua
//

#import "GlobalThresholdingFilter.h"

@implementation GlobalThresholdingFilter

- (void) initPlugin
{
}

- (IBAction)openEmail:(id)sender
{
    
    NSString	*to = @"osirixpluginbasics@googlemail.com",
                *subject = @"(Plugin) Global Thresholding",
                *body = @"";
    
    NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                            [to stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding],
                            [subject stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding],
                            [body stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding]];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: mailString]];
    
}

- (IBAction)openWebsite:(id)sender
{
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://osirixpluginbasics.wordpress.com"]];
    
}

- (void) CreateBrushROI:(id) sender
{
    
    [window orderOut:sender];
    [NSApp endSheet:window returnCode:[sender tag]];
    
    if( [sender tag])   //User clicks OK Button
    {
        
        float		ThresholdLow		= [lowThreshold floatValue];
        float		ThresholdHigh		= [highThreshold floatValue];
        NSString	*ThresholdROIName	= [thresholdROIname stringValue];
        
        int startSlice, endSlice;
        
        
        
        if ([btnCurSlice state] == NSOnState)  // just the current slice
        {
            startSlice = [[viewerController imageView] curImage];
            endSlice = startSlice + 1;
        }
        else  // or all slices in the viewer?
        {
            startSlice = 0;
            endSlice = [[viewerController pixList] count];
        }
        
        if ([chkLowThreshold state] != NSOnState)  // low threshold = off
        {
            
            ThresholdLow = -1000000;
            
        }
        
        if ([chkHighThreshold state] != NSOnState)  // high threshold = off

        {
            ThresholdHigh = 1000000;
            
        }
        
        if (([chkLowThreshold state] != NSOnState) && ([chkHighThreshold state] != NSOnState))
        {
            // low + high threshold = off
            ThresholdLow = 1;
            ThresholdHigh = -1;
            return;
        }
        
        
        
        for (int i = startSlice; i < endSlice; i++)
        {
            
            DCMPix	*curPix = [[viewerController pixList] objectAtIndex:i];
            float	*fImage = [curPix fImage];
            
            BOOL	RoiEmpty = TRUE;
            
            // create array with the same size as the current image
            float			SumOfPixel = [curPix pwidth] * [curPix pheight];
            unsigned char	*textureBuffer = (unsigned char*)malloc(SumOfPixel*sizeof(unsigned char));
            
            for (int x = 0; x< SumOfPixel; x++)
            {
                
                if ((fImage[x] >= ThresholdLow) && (fImage[x] <= ThresholdHigh))
                {
                    textureBuffer[x] = 0xFF;
                    RoiEmpty = FALSE;
                }
                else
                {
                    textureBuffer[x] = 0x00;
                }
                
            }
            
            if (!RoiEmpty)
            {
                ROI		*thresholdROI = nil;
                
                thresholdROI = [[[ROI alloc] initWithTexture:textureBuffer
                                                   textWidth:[curPix pwidth] textHeight:[curPix pheight]
                                                    textName:ThresholdROIName positionX:0 positionY:0
                                                    spacingX:[curPix pixelSpacingX]
                                                    spacingY:[curPix pixelSpacingY]
                                                 imageOrigin:NSMakePoint( [curPix originX],
                                                                         [curPix originY])] autorelease];
                
                NSMutableArray	*roiImageList = [[viewerController roiList] objectAtIndex: i];
                
                [roiImageList addObject: thresholdROI];
                
                // update viewer
                [viewerController needsDisplayUpdate];
                
            }
            
            // don't forget to free the memory !!!
            free(textureBuffer);
            
        }
        
    }
    
    
}

- (void) SetSignalIntensity
{
    float maxValue = 0;
    float minValue = 0;
    
    for (unsigned int i = 0; i < [[viewerController pixList] count]; i++)
    {
        DCMPix	*curPix = [[viewerController pixList] objectAtIndex: i];
        float	*fImage = [curPix fImage];
        
        int SumOfPixels = [curPix pwidth] * [curPix pheight];
        
        for (int j = 0; j < SumOfPixels; j++)
        {
            
            if (fImage[j] > maxValue)
            {
                maxValue = fImage[j];
            } else
            if (fImage[j] < minValue)
            {
                minValue = fImage[j];
            }
            
        }
        
    }
    
    [highThreshold setFloatValue: maxValue];
    [lowThreshold setFloatValue: minValue];
    
}

- (long) filterImage:(NSString*) menuName
{
    [NSBundle loadNibNamed:@"GlobalThreshold_Dialog" owner:self];
    [NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
    
    
    [self SetSignalIntensity];
    
    
    return 0;
}


@end

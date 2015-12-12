//
//  AppDelegate.m
//  Macsplorer
//
//  Created by Jonas Peter Hyatt on 09/12/15.
//  Copyright © 2015 Jonas Peter Hyatt. All rights reserved.
//

#import "AppDelegate.h"
@import ORSSerial;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
- (void) sendValueToSerialDisplay:(NSString*) value;
- (void) openSerialConnection:(ORSSerialPort*) port :(int) rate;
- (void) createNewTab;
- (void) sendToDevice;
- (void)findAvaliablePortsAndSetPopupButtons;
@end

@implementation AppDelegate

@synthesize fileManipultaionButtonsOutlet;
@synthesize baudRateSelector;
@synthesize serialDeviceSelector;
@synthesize deviceInteractionButtonsOutlet;
@synthesize sendToSerialTextboxOutlet;
@synthesize tabbedTextEditor;
@synthesize terminalTextView;

NSArray *ports;
ORSSerialPort* selectedPort;
int baudRate;
NSMutableArray* tabViewItemTextViews;
int idSequence;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    idSequence = 0;
    baudRate = 9600;
    [self findAvaliablePortsAndSetPopupButtons];
    selectedPort = [ports objectAtIndex:1];
    [self sendValueToSerialDisplay:@"\n> "];
    tabViewItemTextViews = [[NSMutableArray alloc] init];
}

- (void)findAvaliablePortsAndSetPopupButtons {
    ports = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
    [serialDeviceSelector removeAllItems];
    [serialDeviceSelector addItemWithTitle:@"-- Select serial device --"];
    for (ORSSerialPort* port in ports) {
        [serialDeviceSelector addItemWithTitle:[port name]];
    }
    
    if (selectedPort != nil) {
        NSUInteger portIndex = [ports indexOfObject:selectedPort];
        if (portIndex != NSNotFound) {
            selectedPort = [ports objectAtIndex:portIndex];
            [serialDeviceSelector selectItemAtIndex:portIndex + 1];
      }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (selectedPort) {
        [selectedPort close];
    }
}

- (IBAction)deviceInteractionButtonsAction:(id)sender {
    NSLog(@"Device interaction button pressed:");
    NSInteger tagForClickedButton = [[sender cell] tagForSegment:[sender selectedSegment]];
    // NSSegmentedControl* button = [deviceInteractionButtonsOutlet ] [sender selectedSegment];
    
    switch (tagForClickedButton) {
        case 0: // Open/Close Connection button
            if ([selectedPort isOpen]) {
                [selectedPort close];
                [deviceInteractionButtonsOutlet setLabel:@"Open connection!" forSegment:[sender selectedSegment]];
            }
            else {
                [self openSerialConnection:selectedPort :baudRate];
                [deviceInteractionButtonsOutlet setLabel:@"Close connection!" forSegment:[sender selectedSegment]];
            }
            
            break;
            
        case 1: // Flash firmware to device button
            NSLog(@"Flash firmware to device button clicked");
            break;
            
        case 2: // Refresh devices button
            NSLog(@"Refresh devices button clicked");
            [self findAvaliablePortsAndSetPopupButtons];
            break;
        
        case 3:
            [self sendToDevice];
            break;
            
        default:
            break;
    }
}

- (void) sendToDevice {
    if ([[tabbedTextEditor tabViewItems] count] > 0 && selectedPort) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTextView* theText = [tabViewItemTextViews objectAtIndex:[tabbedTextEditor indexOfTabViewItem:[tabbedTextEditor selectedTabViewItem]]];
            NSArray* commandsToSend = [[theText string] componentsSeparatedByString:@"\n"];
            for (NSString* command in commandsToSend) {
                [self sendValueToSerial:command];
                [NSThread sleepForTimeInterval:0.5f];
            }
        });
    }
}

- (IBAction)sendToSerialTextboxAction:(id)sender {
    [self sendValueToSerial:[sendToSerialTextboxOutlet stringValue]];
    sendToSerialTextboxOutlet.stringValue = @"";
}

- (IBAction)sendToSerialButton:(id)sender {
    [self sendValueToSerial:[sendToSerialTextboxOutlet stringValue]];
    sendToSerialTextboxOutlet.stringValue = @"";
}

- (IBAction)fileManipulationButtonsAction:(NSSegmentedControl *)sender {
    NSLog(@"file manipulation button pressed");
    NSInteger tagForClickedButton = [[sender cell] tagForSegment:[sender selectedSegment]];
    
    switch (tagForClickedButton) {
        case 0: // New button
            NSLog(@"New button clicked");
            [self createNewTab];
            break;
            
        case 1: // Open button
            NSLog(@"Open button clicked");
            break;
            
        case 2: // Save button
            NSLog(@"Save button clicked");
            break;
            
        case 3: // Close button
            NSLog(@"Close button clicked");
            break;
            
        case 4: // Line button
            NSLog(@"Line button clicked");
            break;
            
        default:
            break;
    }
}

- (void) createNewTab {
    // Initiate new tab
    idSequence = idSequence + 1;
    NSTabViewItem* myTab = [[NSTabViewItem alloc] initWithIdentifier:[NSNumber numberWithInt:idSequence]];
    myTab.label = @"Scratchpad";
    
    // Add the tab to the editor and select it.
    [tabbedTextEditor addTabViewItem:myTab];
    [tabbedTextEditor selectLastTabViewItem:nil];
    
    // Initiate a scrollview
    NSScrollView* theScroll = [[NSScrollView alloc] initWithFrame:myTab.view.bounds];
    
    // Set scroll view options
    NSSize contentSize = [theScroll contentSize];
    [theScroll setBorderType:NSNoBorder];
    [theScroll setHasVerticalScroller:YES];
    [theScroll setHasHorizontalScroller:NO];
    [theScroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Initiate a textview
    NSTextView *theTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    
    // Set text view sizing options
    [theTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [theTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [theTextView setVerticallyResizable:YES];
    [theTextView setHorizontallyResizable:NO];
    [theTextView setAutoresizingMask:NSViewWidthSizable];
    [[theTextView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[theTextView textContainer] setWidthTracksTextView:YES];
    
    // Set the text views properties to sane code editing
    [theTextView setSelectable:YES];
    [theTextView setAllowsUndo:YES];
    [theTextView setEditable:YES];
    
    [theTextView setRichText:NO];
    [theTextView setSmartInsertDeleteEnabled:NO];
    [theTextView setContinuousSpellCheckingEnabled:NO];
    [theTextView setAutomaticQuoteSubstitutionEnabled:NO];
    [theTextView setAutomaticLinkDetectionEnabled:NO];
    [theTextView setAutomaticDataDetectionEnabled:NO];
    [theTextView setAutomaticDashSubstitutionEnabled:NO];
    [theTextView setAllowsImageEditing:NO];
    
    [theTextView setFont:[NSFont fontWithName:@"Menlo Regular" size:12.0]];
    
    theTextView.continuousSpellCheckingEnabled = NO;
    theTextView.grammarCheckingEnabled = NO;
    theTextView.automaticSpellingCorrectionEnabled = NO;
    theTextView.automaticTextReplacementEnabled = NO;
    
    // add the text view to the scrollview
    [theScroll addSubview:theTextView];
    [theScroll setAutoresizesSubviews:YES];
    
    // add the scrollview to the tab
    [myTab.view addSubview:theScroll];
    [myTab.view setAutoresizesSubviews:YES];
    
    // Set the scroll views document to the text view (enables scrolling)
    [theScroll setDocumentView:theTextView];
    
    // Become first responder
    [theTextView becomeFirstResponder];
    
    // add the texteditor from the tab to a tracking array.
    [tabViewItemTextViews addObject:theTextView];
}

- (IBAction)baudRateSelectorAction:(id)sender {
    int baudRates[13] = {0, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 230400, 460800, 921600};
    
    NSPopUpButton *btn = (NSPopUpButton*)sender;
    NSInteger index = [btn indexOfSelectedItem];
    baudRate = baudRates[index];
}

- (IBAction)serialDeviceSelectorAction:(id)sender {
    NSPopUpButton *btn = (NSPopUpButton*)sender;
    NSInteger index = [btn indexOfSelectedItem];
    if (index > 0) {
        selectedPort = [ports objectAtIndex:index - 1];
    }
}

- (void)sendValueToSerial:(NSString*) value {
    NSData *dataToSend = [[NSString stringWithFormat:@"%@ \n", value] dataUsingEncoding:NSUTF8StringEncoding];
    [selectedPort sendData:dataToSend];
}

- (void)sendValueToSerialDisplay:(NSString*) value {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* termString = [NSString stringWithFormat:@"%@", value];
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:termString];
        
        [[terminalTextView textStorage] appendAttributedString:attr];
        [terminalTextView scrollRangeToVisible:NSMakeRange([[terminalTextView string] length], 0)];
    });
}

- (void) openSerialConnection:(ORSSerialPort*) port :(int) rate {
    port.baudRate = [NSNumber numberWithInt:rate];
    port.parity = ORSSerialPortParityNone;
    port.numberOfStopBits = 1;
    [port setDelegate:self];
    [port open];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort {
    selectedPort = nil;
    NSLog(@"Serial port was removed from this system!");
    [self sendValueToSerialDisplay:@"Serial port was removed from this system!"];
    [self sendValueToSerialDisplay:@"\n> "];
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self sendValueToSerialDisplay:string];
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort {
    NSLog(@"Serial port was opened!");
    [self sendValueToSerialDisplay:@"Serial port was opened!"];
    [self sendValueToSerialDisplay:@"\n> "];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort {
    NSLog(@"Serial port was closed!");
    [self sendValueToSerialDisplay:@"Serial port was closed!"];
    [self sendValueToSerialDisplay:@"\n> "];
}

@end


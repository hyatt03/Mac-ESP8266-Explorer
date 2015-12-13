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
NSArray* blueWords;
NSMutableDictionary* keyWords;

#define ALPHABET_LEN 256
#define NOT_FOUND patlen
#define max(a, b) ((a < b) ? b : a)


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // initialize the id sequence for text views
    idSequence = 0;
    
    // Set default baudrate
    baudRate = 9600;
    
    // find availiable ports
    [self findAvaliablePortsAndSetPopupButtons];
    
    // set the first port as the default port
    selectedPort = [ports objectAtIndex:1];
    
    // Send input char to serial (cosmetic)
    [[terminalTextView textStorage] setDelegate:nil];
    [self sendValueToSerialDisplay:@"\n> "];
    
    // Initialize the tabviewitemtextviews array to keep references to textview for retrieving text when sending to device.
    tabViewItemTextViews = [[NSMutableArray alloc] init];
    
    // Register for text storage notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(textStorageDidProcessEditing:)
                                          name:NSTextStorageDidProcessEditingNotification object:nil];
    
    // Setup words for syntax highlighting
    /* keyWords = [[NSMutableDictionary alloc] init];
    NSColor * blue = [NSColor blueColor];
    NSColor * green = [NSColor colorWithCalibratedRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0];
    NSColor * red = [NSColor redColor];
    
    [keyWords setObject: green forKey: @"do"];
    [keyWords setObject: green forKey: @"end"];
    [keyWords setObject: blue forKey: @"while"];
    [keyWords setObject: blue forKey: @"if"];
    [keyWords setObject: red forKey: @"quote-color"];
     */

    // blueWords = [[NSArray alloc] initWithObjects:@"while", @"if", nil];
    
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
                NSLog(command);
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
    
    // add the texteditor from the tab to a tracking array.
    [tabViewItemTextViews addObject:theTextView];
    
    // Setup syntax highlighting
    [[theTextView textStorage] setDelegate:self];
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

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    blueWords = [[NSArray alloc] initWithObjects:@"local", @"and", @"break", @"do", @"else", @"elseif", @"end", @"false", @"for", @"function", @"if", @"in", @"nil", @"not", @"or", @"repeat", @"return", @"then", @"true", @"until", @"while", nil];
    
    NSTextStorage *textStorage = [notification object];
    NSString *string = [textStorage string];
    NSInteger stringlen = [string length];
    
    [textStorage removeAttribute:NSForegroundColorAttributeName
                           range:NSMakeRange(0, stringlen)];
    
    for (NSInteger i = [blueWords count]; i > 0; i--) {
        NSString* pat = [blueWords objectAtIndex:i - 1];
        NSInteger patlen = [pat length];
        unichar patfirstchar = [pat characterAtIndex:0];
        
        for (NSInteger x = [string length]; x > 0; x--) {
            NSInteger y = x - 1;
            if (stringlen > y + patlen && y - 1 >= 0) { // check that index + pattern is not greater than the length of the entire string.
                unichar charbefore = [string characterAtIndex:y - 1];
                unichar charafter = [string characterAtIndex:y + patlen];
                if (
                    [string characterAtIndex:y] == patfirstchar && // Check that the char is equal to the first char of the pattern.
                    (y == 0 || charbefore == ' ' || charbefore == '\n') && // Check that the char before is either a space or a newline
                    (charafter == ' ' || charafter == '\n')
                    )
                {
                    NSRange wordRange = NSMakeRange(y, patlen);
                    if ([[string substringWithRange:wordRange] isEqualToString:pat]) {
                        [textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:wordRange];
                    }
                }
            }
            else if (y == 0 && stringlen > y + patlen) { // this is the first char.
                unichar charafter = [string characterAtIndex:y + patlen];
                if ([string characterAtIndex:y] == patfirstchar && (charafter == ' ' || charafter == '\n')) {
                    NSRange wordRange = NSMakeRange(y, patlen);
                    if ([[string substringWithRange:wordRange] isEqualToString:pat]) {
                        [textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:wordRange];
                    }
                }
            }
            else if (stringlen > y + patlen && [string characterAtIndex:y] == patfirstchar) {
                NSRange wordRange = NSMakeRange(y, patlen);
                if ([[string substringWithRange:wordRange] isEqualToString:pat]) {
                    [textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:wordRange];
                }
            }
        }
    }
}

@end


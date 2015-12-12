//
//  AppDelegate.h
//  Macsplorer
//
//  Created by Jonas Peter Hyatt on 09/12/15.
//  Copyright © 2015 Jonas Peter Hyatt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ORSSerial/ORSSerial.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, ORSSerialPortDelegate>

// File manipulating buttons
@property (weak) IBOutlet NSSegmentedControl *fileManipultaionButtonsOutlet;
- (IBAction)fileManipulationButtonsAction:(NSSegmentedControl *)sender;


// Selectors
@property (weak) IBOutlet NSPopUpButton *baudRateSelector;
@property (weak) IBOutlet NSPopUpButton *serialDeviceSelector;
- (IBAction)baudRateSelectorAction:(id)sender;
- (IBAction)serialDeviceSelectorAction:(id)sender;

// Device interactions buttons
@property (weak) IBOutlet NSSegmentedControl *deviceInteractionButtonsOutlet;
@property (weak) IBOutlet NSTextField *sendToSerialTextboxOutlet;
- (IBAction)deviceInteractionButtonsAction:(id)sender;
- (IBAction)sendToSerialTextboxAction:(id)sender;
- (IBAction)sendToSerialButton:(id)sender;

// Tab controller for text editor
@property (weak) IBOutlet NSTabView *tabbedTextEditor;

// Scrollview for terminal output
@property (unsafe_unretained) IBOutlet NSTextView *terminalTextView;

// Serial stuff
- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data;
- (void)serialPortWasOpened:(ORSSerialPort *)serialPort;
- (void)serialPortWasClosed:(ORSSerialPort *)serialPort;

@end

//
//  AppDelegate.m
//  Fredrik
//
//  Created by Simon Andersson on 10/1/13.
//  Copyright (c) 2013 Monterosa AB. All rights reserved.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "GHMarkdownParser.h"
#import "DDHotKeyCenter.h"
#import "Finder.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
    [c registerHotKeyWithKeyCode:0x2E modifierFlags:(NSCommandKeyMask|NSShiftKeyMask) task:^(NSEvent *event) {
        
        FinderApplication * finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
        SBElementArray * selection = [[finder selection] get];
        
        NSArray * items = [selection arrayByApplyingSelector:@selector(URL)];
        for (NSString * item in items) {
            
            NSString *filename = [item lastPathComponent];
            NSString *ext = [filename pathExtension];
            NSURL *url = [NSURL URLWithString:item];
            if ([[ext lowercaseString] isEqualToString:@"md"]) {
                [self storeAndParseURL:url];
            }
        }
    }];
}

- (IBAction)browserClick:(id)sender {
    NSOpenPanel *dialog = [[NSOpenPanel alloc] init];
    [dialog setCanChooseDirectories:NO];
    [dialog setCanChooseFiles:YES];
    if ([dialog runModal] == NSOKButton) {
        NSArray *files = [dialog URLs];
        
        for (NSURL *url in files) {
            
            NSString *filename = [[url absoluteString] lastPathComponent];
            NSString *ext = [filename pathExtension];
            if ([[ext lowercaseString] isEqualToString:@"md"]) {
                [self storeAndParseURL:url];
            }
        }
    }
}

- (void)storeAndParseURL:(NSURL *)url {
    
    NSString *md = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSString *css = @"html{font-size:100%;overflow-y:scroll;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;}body{width:660px;color:#444;font-family:'Helvetica Neue', Helvetica, Arial;font-size:14px;line-height:1.5em;max-width:100%;background:#fefefe;margin:auto;padding:1em;}a{color:#0645ad;text-decoration:none;}a:visited{color:#0b0080;}a:hover{color:#06e;}a:active{color:#faa700;}a:focus{outline:thin dotted;}a:hover,a:active{outline:0;}p{margin:1em 0;}img{max-width:100%;border:0;-ms-interpolation-mode:bicubic;vertical-align:middle;}h1,h2,h3,h4,h5,h6{font-weight:800;color:#111;line-height:1em;}h1{font-size:2.5em;}h2{font-size:2em;}h3{font-size:1.5em;}h4{font-size:1.2em;}h5{font-size:1em;}h6{font-size:.9em;}blockquote{color:#666;padding-left:1em;border-left:.5em #EEE solid;margin:0;}\
    hr {\
        display:block;height:4px;border:0 none;margin:15px 0;color:#ccc;padding:0;background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAECAYAAACtBE5DAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNSBNYWNpbnRvc2giIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OENDRjNBN0E2NTZBMTFFMEI3QjRBODM4NzJDMjlGNDgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OENDRjNBN0I2NTZBMTFFMEI3QjRBODM4NzJDMjlGNDgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo4Q0NGM0E3ODY1NkExMUUwQjdCNEE4Mzg3MkMyOUY0OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo4Q0NGM0E3OTY1NkExMUUwQjdCNEE4Mzg3MkMyOUY0OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PqqezsUAAAAfSURBVHjaYmRABcYwBiM2QSA4y4hNEKYDQxAEAAIMAHNGAzhkPOlYAAAAAElFTkSuQmCC) repeat-x 0 0; \
    }\
    dfn{font-style:italic;}ins{background:#ff9;color:#000;text-decoration:none;}mark{background:#ff0;color:#000;font-style:italic;font-weight:700;}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline;}sup{top:-.5em;}sub{bottom:-.25em;}ul,ol{margin:1em 0;padding:0 0 0 2em;}li p:last-child{margin:0;}dd{margin:0 0 0 2em;}table{border-collapse:collapse;border-spacing:0;}td{vertical-align:top;}::-moz-selection,::selection{background:rgba(255,255,0,0.3);color:#000;}a::-moz-selection,a::selection{background:rgba(255,255,0,0.3);color:#0645ad;}h4,h5,h6,b,strong{font-weight:700;}@media only screen and min-width 480px{body{font-size:14px;}}@media only screen and min-width 768px{body{font-size:16px;}}code,pre{font-family:Monaco, Andale Mono, Courier New, monospace;}code{background-color:#fee9cc;color:rgba(0,0,0,0.75);font-size:12px;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;padding:1px 3px;}pre{display:block;line-height:16px;font-size:13px;border:1px solid #d9d9d9;white-space:pre-wrap;word-wrap:break-word;margin:0 0 18px;padding:10px 0;}pre code{background-color:#fff;color:#737373;font-size:13px;padding:0;}";
    
    NSString *filename = [[[url absoluteString] lastPathComponent] stringByDeletingPathExtension];
    NSString *output = [NSString stringWithFormat:@"<style>%@</style><body>%@</body>", css, md.flavoredHTMLStringFromMarkdown];
    NSError *error = nil;
    
    [output writeToURL:[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", filename] isDirectory:NO] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:[NSString stringWithFormat:@"Export failed."]];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:0];
        [NSApp requestUserAttention:NSCriticalRequest];
    }
    else {
        [NSApp requestUserAttention:NSInformationalRequest];
    }
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *path in filenames) {
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        NSString *filename = [[url absoluteString] lastPathComponent];
        NSString *ext = [filename pathExtension];
        if ([[ext lowercaseString] isEqualToString:@"md"]) {
            [self storeAndParseURL:url];
        }
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if(flag==NO){
		[self.window makeKeyAndOrderFront:self];
	}
	return YES;
}

@end

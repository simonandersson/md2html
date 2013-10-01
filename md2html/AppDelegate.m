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
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
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
    
    NSString *css = @"html{font-size:100%;overflow-y:scroll;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;}body{color:#444;font-family:'Helvetica Neue', Helvetica, Arial;font-size:14px;line-height:1.5em;max-width:100%;background:#fefefe;margin:auto;padding:1em;}a{color:#0645ad;text-decoration:none;}a:visited{color:#0b0080;}a:hover{color:#06e;}a:active{color:#faa700;}a:focus{outline:thin dotted;}a:hover,a:active{outline:0;}p{margin:1em 0;}img{max-width:100%;border:0;-ms-interpolation-mode:bicubic;vertical-align:middle;}h1,h2,h3,h4,h5,h6{font-weight:800;color:#111;line-height:1em;}h1{font-size:2.5em;}h2{font-size:2em;}h3{font-size:1.5em;}h4{font-size:1.2em;}h5{font-size:1em;}h6{font-size:.9em;}blockquote{color:#666;padding-left:3em;border-left:.5em #EEE solid;margin:0;}hr{display:block;height:2px;border:0;border-top:1px solid #aaa;border-bottom:1px solid #eee;margin:1em 0;padding:0;}dfn{font-style:italic;}ins{background:#ff9;color:#000;text-decoration:none;}mark{background:#ff0;color:#000;font-style:italic;font-weight:700;}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline;}sup{top:-.5em;}sub{bottom:-.25em;}ul,ol{margin:1em 0;padding:0 0 0 2em;}li p:last-child{margin:0;}dd{margin:0 0 0 2em;}table{border-collapse:collapse;border-spacing:0;}td{vertical-align:top;}::-moz-selection,::selection{background:rgba(255,255,0,0.3);color:#000;}a::-moz-selection,a::selection{background:rgba(255,255,0,0.3);color:#0645ad;}h4,h5,h6,b,strong{font-weight:700;}@media only screen and min-width 480px{body{font-size:14px;}}@media only screen and min-width 768px{body{font-size:16px;}}@media print{*{background:transparent!important;color:#000!important;filter:none!important;-ms-filter:none!important;}body{font-size:12pt;max-width:100%;}a,a:visited{text-decoration:underline;}hr{height:1px;border:0;border-bottom:1px solid #000;}a[href]:after{content:\" (\" attr(href) \")\";}abbr[title]:after{content:\" (\" attr(title) \")\";}.ir a:after,a[href^=javascript:]:after,a[href^=#]:after{content:"";}pre,blockquote{border:1px solid #999;padding-right:1em;page-break-inside:avoid;}tr,img{page-break-inside:avoid;}img{max-width:100%!important;}p,h2,h3{orphans:3;widows:3;}h2,h3{page-break-after:avoid;}}code,pre{font-family:Monaco, Andale Mono, Courier New, monospace;}code{background-color:#fee9cc;color:rgba(0,0,0,0.75);font-size:12px;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;padding:1px 3px;}pre{display:block;line-height:16px;font-size:13px;border:1px solid #d9d9d9;white-space:pre-wrap;word-wrap:break-word;margin:0 0 18px;padding:14px;}pre code{background-color:#fff;color:#737373;font-size:13px;padding:0;}";
    
    NSString *filename = [[[url absoluteString] lastPathComponent] stringByDeletingPathExtension];
    NSString *output = [NSString stringWithFormat:@"<style>%@</style><body>%@</body>", css, md.flavoredHTMLStringFromMarkdown];
    NSError *error = nil;
    
    [output writeToURL:[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", filename] isDirectory:NO] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:[NSString stringWithFormat:@"Export succeded.\nFile can be found at: %@", [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", filename]].relativePath ]];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:0];
    }
}

@end

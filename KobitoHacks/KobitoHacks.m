//
//  KobitoHacks.m
//  KobitoHacks

#import "KobitoHacks.h"

#import <WebKit/WebKit.h>
#import <objc/message.h>

IMP Replace_MethodImp_WithFunc(Class aClass, SEL origSel, const void* repFunc)
{
    Method origMethod;
    IMP oldImp = NULL;
    if (aClass && (origMethod = class_getInstanceMethod(aClass, origSel))){
        oldImp=method_setImplementation(origMethod, repFunc);
        
    }
    return oldImp;
}


//- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)URL;

void (*orig_loadHTMLString)(id, SEL, id, id);
//IMP orig_loadHTMLString; //ARC だと IMP では落ちる
void KH_loadHTMLString(id self, SEL _cmd, NSString* string, NSURL* baseURL){

    if (![[self webView]resourceLoadDelegate]) {
        [[self webView]setResourceLoadDelegate:[KHResourceLoadDelegate sharedInstance]];
    }
    
    orig_loadHTMLString(self, _cmd, string, baseURL);
}






@implementation KHResourceLoadDelegate
+ (KHResourceLoadDelegate*)sharedInstance
{
    static KHResourceLoadDelegate *sharedInstance;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[KHResourceLoadDelegate alloc] init];
    });
    return sharedInstance;
}


- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    //file scheme 以外は無視
    if (![[request URL]isFileURL]) {
        return request;
    }
    
    //存在する場合もそのまま返す
    NSString* path=[[request URL]path];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return request;
    }
    
    //delegate 経由で Item をとってきてファイルと連携してるか調べる
    id deleg=[sender frameLoadDelegate];
    if (!deleg) {
        deleg=[sender policyDelegate];
    }

    id item=nil;
    NSString* linkedFilePath=nil;
    NSString* localPath=nil;
    //defaults write com.qiita.Kobito KobitoHacksResourcePath "/path/to/images"
    //とかするとそこを参照
    NSString* defaultPath=[[NSUserDefaults standardUserDefaults]stringForKey:@"KobitoHacksResourcePath"];
    
    //EditController
    if ([deleg respondsToSelector:@selector(item)]) {
        item=objc_msgSend(deleg, @selector(item));
        
    //ItemsController : NSArrayController
    }else if ([deleg respondsToSelector:@selector(selectedObjects)]) {
        NSArray* items=objc_msgSend(deleg, @selector(selectedObjects));
        if ([items count]>0) {
            item=[items objectAtIndex:0];
        }
    }
    //Item
    if ([item respondsToSelector:@selector(linked_file)]) {
        linkedFilePath=objc_msgSend(item, @selector(linked_file));
    }
    if (linkedFilePath) {
        localPath=[linkedFilePath stringByDeletingLastPathComponent];
    }

    //フォルダなし。帰る
    if (![localPath length] && ![defaultPath length]) {
        return request;
    }


    //ファイルがあるか調べる
    NSString* resourcePath=[[NSBundle mainBundle]resourcePath];
    if ([path hasPrefix:resourcePath]) {
        NSString* suffix=[path substringFromIndex:[resourcePath length]];
        NSString* localResource=nil;
        NSURL* newURL=nil;
        if([localPath length]){
            localResource=[localPath stringByAppendingPathComponent:suffix];
            if([[NSFileManager defaultManager]fileExistsAtPath:localResource]) {
                newURL=[NSURL fileURLWithPath:localResource];
            }
        }
        if(!newURL && [defaultPath length]){
            localResource=[defaultPath stringByAppendingPathComponent:suffix];
            if ([[NSFileManager defaultManager]fileExistsAtPath:localResource]){
                newURL=[NSURL fileURLWithPath:localResource];
            }
        }
        if (newURL) {
            return [NSURLRequest requestWithURL:newURL];
        }
    }


    return request;
}
@end







@implementation KHSimblLoader
+(void)install
{
    LOG(@"KobitoHacks");
    orig_loadHTMLString=(void(*)(id,SEL,id,id))Replace_MethodImp_WithFunc(NSClassFromString(@"WebFrame"),
                       @selector(loadHTMLString:baseURL:), KH_loadHTMLString);
}

@end

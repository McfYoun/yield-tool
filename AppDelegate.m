

#import "AppDelegate.h"
@interface AppDelegate ()<NSTableViewDataSource,NSTableViewDelegate,NSWindowDelegate>
{

    NSButton *_actionBtn;
}
@property (weak) IBOutlet NSWindow * window;
@property (nonatomic) NSTableView * tableView;
@property (nonatomic,strong) NSString * addcommandStr;
@property (nonatomic,strong) NSTextField * textField1;

@property (nonatomic,strong) NSTextField * stationInfo;
@property (nonatomic,strong) NSTextField * totalResult;
@property (nonatomic,strong) NSTextField * slot1Result;
@property (nonatomic,strong) NSTextField * slot2Result;
@property (nonatomic,strong) NSTextField * slot3Result;
@property (nonatomic,strong) NSTextField * slot4Result;


@end

@implementation AppDelegate

-(NSSize)windowWillResize:(NSWindow *)sender
                   toSize:(NSSize)frameSize{
    //获取NSwindow及长宽
    frameSize.width = 542;
    frameSize.height = 376;
    return frameSize;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self CreateTextField];
    [_window setDelegate:self];
    [self CreateBtn];
    [self awakeFromNib];
}

- (void)CreateBtn
{
    //执行按钮
    _actionBtn = [[NSButton alloc] initWithFrame:CGRectMake(50, 15, 70, 25)];
    _actionBtn.title = @"执行代码";
    _actionBtn.wantsLayer = YES;
    _actionBtn.layer.cornerRadius = 3.0f;
    _actionBtn.layer.borderColor = [NSColor blackColor].CGColor;
    [_actionBtn setTarget:self];
    _actionBtn.action = @selector(ActionTheCommand);
    
    
    [self.window.contentView addSubview:_actionBtn];
}


- (void)ActionTheCommand
{
//    NSString * MutableString = [_dataSourceArray componentsJoinedByString:@","];
//    NSString * finalString = [MutableString stringByReplacingOccurrencesOfString:@"," withString:@";"];
//NSString * CMD = [[NSString alloc] initWithFormat:@"find /Users/bp/Desktop/DailyReport/J132/2018/02/04/Archive -mtime -%@h",_YieldTime.stringValue];
    
    NSString * finalString = [[NSString alloc] initWithFormat:@"find /vault/Atlas/Units/Archive -mtime -%@ | grep tgz",_textField1.stringValue];
    // 创建
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(ConnectTerminal:) object:finalString];
    
    // 启动
    [thread start];
//    [self ConnectTerminal:finalString];
//    NSLog(@"%@\n\n%@",MutableString,finalString);
//    [self Archiver];
    return;
}

- (void)ConnectTerminal:(NSString *)FFinalString
{
    NSTask *task;
    task = [[NSTask alloc] init];
    
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-c",FFinalString,nil];
    [task setArguments: arguments];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
//    NSLog (@"got\n%@", string);
    [self analyseString:string];
    
//    [[NSRunLoop currentRunLoop] run];
}

- (void)analyseString:(NSString *)resultStr
{
    if (!resultStr) {
        return;
    }
    NSArray * resultArr = [resultStr componentsSeparatedByString:@"\n"];
    
    NSMutableArray * slot1Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot2Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot3Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot4Arr = [[NSMutableArray alloc] init];
    
    NSString * totalresult = [[NSString alloc] init];
    NSString * slot1result = [[NSString alloc] init];
    NSString * slot2result = [[NSString alloc] init];
    NSString * slot3result = [[NSString alloc] init];
    NSString * slot4result = [[NSString alloc] init];
    
    float passCount = 0;
    
    for (NSString * totalcountstr in resultArr) {
        if ([totalcountstr containsString:@"Pass"]) {
            passCount ++;
        }
    }
    totalresult = [[NSString alloc] initWithFormat:@"total,input_%lu,Pass_%ld,Yield_%0.2f",resultArr.count - 1,(long)passCount,passCount/(resultArr.count - 1)];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_totalResult setStringValue:totalresult];
    });

    passCount = 0;
    
    for (NSString * str in resultArr) {
        if ([str containsString:@"Slot-1"]) {
            [slot1Arr addObject:str];
        }
        if ([str containsString:@"Slot-2"]) {
            [slot2Arr addObject:str];
        }
        if ([str containsString:@"Slot-3"]) {
            [slot3Arr addObject:str];
        }
        if ([str containsString:@"Slot-4"]) {
            [slot4Arr addObject:str];
        }
    }
    
    if (slot1Arr.count > 0) {
        for (NSString * slotstr in slot1Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot1result = [NSString stringWithFormat:@"slot1,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot1Arr.count,(long)passCount,passCount/slot1Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_slot1Result setStringValue:slot1result];
        });
    }
    
    
    
    passCount = 0;
    
    if (slot2Arr.count > 0) {
        for (NSString * slotstr in slot2Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot2result = [NSString stringWithFormat:@"slot2,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot2Arr.count,(long)passCount,passCount/slot2Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_slot2Result setStringValue:slot2result];
        });
        
    }
    
    passCount = 0;
    if (slot3Arr.count > 0) {
        for (NSString * slotstr in slot3Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot3result = [NSString stringWithFormat:@"slot3,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot3Arr.count,(long)passCount,passCount/slot3Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_slot3Result setStringValue:slot3result];
        });
        
    }
    
    passCount = 0;
    if (slot4Arr.count > 0) {
        for (NSString * slotstr in slot4Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot4result = [NSString stringWithFormat:@"slot4,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot4Arr.count,(long)passCount,passCount/slot4Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_slot4Result setStringValue:slot4result];
        });
        
    }
    
    
}

- (void)CreateTextField
{
    
    self.stationInfo = [[NSTextField alloc] initWithFrame:CGRectMake(110, 300, 190, 25)];
    [self.window.contentView addSubview:_stationInfo];
    _stationInfo.placeholderString = @"please input station Info";
    
    self.textField1 = [[NSTextField alloc] initWithFrame:CGRectMake(50, 300, 50, 25)];
    [self.window.contentView addSubview:_textField1];
    _textField1.placeholderString = @"time";
    
    self.totalResult = [[NSTextField alloc] initWithFrame:CGRectMake(50, 250, 250, 25)];
    [self.window.contentView addSubview:_totalResult];
    _totalResult.placeholderString = @"totalResult";
    [_totalResult setEditable:NO];
    
    self.slot1Result = [[NSTextField alloc] initWithFrame:CGRectMake(50, 200, 250, 25)];
    [self.window.contentView addSubview:_slot1Result];
    _slot1Result.placeholderString = @"slot1Result";
    [_slot1Result setEditable:NO];
    
    self.slot2Result = [[NSTextField alloc] initWithFrame:CGRectMake(50, 150, 250, 25)];
    [self.window.contentView addSubview:_slot2Result];
    _slot2Result.placeholderString = @"slot2Result";
    [_slot2Result setEditable:NO];
    
    self.slot3Result = [[NSTextField alloc] initWithFrame:CGRectMake(50, 100, 250, 25)];
    [self.window.contentView addSubview:_slot3Result];
    _slot3Result.placeholderString = @"slot3Result";
    [_slot3Result setEditable:NO];
    
    self.slot4Result = [[NSTextField alloc] initWithFrame:CGRectMake(50, 50, 250, 25)];
    [self.window.contentView addSubview:_slot4Result];
    _slot4Result.placeholderString = @"slot4Result";
    [_slot4Result setEditable:NO];
    
//    _addcommandStr = _textField1.stringValue;
}


#pragma mark -
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
@end

//
//  ViewController.m
//  ReactiveCocoaMike
//
//  Created by 佐毅 on 16/2/2.
//  Copyright © 2016年 上海乐住信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "CustomController.h"
static NSString *const mineHomeCellIdentifier = @"mineHomeCellIdentifier";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak)IBOutlet UITableView *mineHomeTableView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)loginBtnAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self.mineHomeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:mineHomeCellIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"tap");
    }];
    [self.view addGestureRecognizer:tap];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RAC" message:@"RAC TEST" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [alertView show];
    
    //创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"signal"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@", x);
    } error:^(NSError *error) {
        NSLog(@"error = %@", error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    
    //映射创建一个订阅者的映射并且返回数据
    [[self.userNameTextField.rac_textSignal map:^id(id value) {
        NSLog(@"%@", value);
        return @1;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [[self.passWordTextField.rac_textSignal map:^id(id value) {
        NSLog(@"%@", value);
        return @1;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //filter 过滤条件判断
    [[self.userNameTextField.rac_textSignal filter:^BOOL(NSString *value) {
        return [value length] > 3;
    }] subscribeNext:^(id x) {
        NSLog(@"x = %@", x);
    }];
    
    RACSignal *validUsernameSignal =
    [self.userNameTextField.rac_textSignal
     map:^id(NSString *text) {
         return @(NO);
     }];
    RACSignal *validPasswordSignal =
    [self.passWordTextField.rac_textSignal
     map:^id(NSString *text) {
         return @(NO);
     }];
    
 
    RAC(self.passWordTextField, backgroundColor) =
    [validPasswordSignal
     map:^id(NSNumber *passwordValid){
         return[passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
     }];
    
    RAC(self.userNameTextField, backgroundColor) =
    [validUsernameSignal
     map:^id(NSNumber *passwordValid){
         return[passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
     }];
    
    //button的点击事件
    [[self.loginBtn
      rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
      
         CustomController *customVC = [[CustomController alloc]init];
         [self.navigationController pushViewController:customVC animated:YES];
     }];
    
    [[self.loginBtn
      rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         
         
     }];
    
    //take skip takeLast takeUntil takeWhileBlock skipWhileBlock skipUntilBlock repeatWhileBlock 都是一样的效果
    RACSignal *signals = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        [subscriber sendCompleted];
        return nil;
    }] skip:2];
    
    [signals subscribeNext:^(id x) {
        NSLog(@"%@take", x);
    }completed:^{
        NSLog(@"completed");
    }];
    
    
    // RACSignal使用步骤：
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 - (void)sendNext:(id)value
    
    
    // RACSignal底层实现：
    // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
    // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
    // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    // 2.1 subscribeNext内部会调用siganl的didSubscribe
    // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
    // 3.1 sendNext底层其实就是执行subscriber的nextBlock
    
    
    //延迟信号
    RACSignal *delaySignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"delay"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2];
    
    
    [delaySignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    NSLog(@"tag");
    
    // throttle节流，在我们做搜索框的时候，有时候需求的时实时搜索，即用户每每输入字符，view都要求展现搜索结果。这时如果用户搜索的字符串较长，那么由于网络请求的延时可能造成UI显示错误，并且多次不必要的请求还会加大服务器的压力，这显然是不合理的，此时我们就需要用到节流。加了节流管道，后面跟上了类型为NSTimeInterval的参数后，只有0.5S内信号不产生变化才会发送请求，这样快速的输入也不会造成多次输出
    
    [[[self.userNameTextField rac_textSignal] throttle:0.5] subscribeNext:^(id x) {
        NSLog(@"throttle节流:%@", x);
    }];


  //  distinctUntilChanged
    
   // 网络请求中为了减轻服务器压力，无用的请求我们应该尽可能不发送。distinctUntilChanged的作用是使RAC不会连续发送两次相同的信号，这样就解决了这个问题。
    
    [[[self.userNameTextField rac_textSignal] distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"distinctUntilChanged:%@", x);
    }];
    

    
    RACSignal *timeOutsignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@"delay"];
            [subscriber sendCompleted];
        }];
        return nil;
    }] timeout:2 onScheduler:[RACScheduler mainThreadScheduler]];
    
    [timeOutsignal subscribeNext:^(id x) {
        NSLog(@"timeOut:%@", x);
    } error:^(NSError *error) {
        NSLog(@"timeOut:%@", error);
    }];
    
    //更新文件信息
    //-------------------------------------------------------------------------------------------------------------------------//
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁");
            
        }];
    }];
    
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];

    //-------------------------------------------------------------------------------------------------------------------------//

    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
    
    //-------------------------------------------------------------------------------------------------------------------------//

    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
    
    //-------------------------------------------------------------------------------------------------------------------------//

    RACSignal *singal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"one"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *singal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"two"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *singal3 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"three"];
        [subscriber sendCompleted];
        return nil;
    }];
    //连接组队列:将几个信号放进一个组里面,按顺序连接每个,每个信号必须执行sendCompleted方法后才能执行下一个信号
    RACSignal *singalGroup = [[singal1 concat:singal2] concat:singal3];
    [singalGroup subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:mineHomeCellIdentifier];
    tableViewCell.textLabel.text = @"2323";
    tableViewCell.textLabel.textColor = [UIColor orangeColor];
    return tableViewCell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)loginBtnAction:(id)sender {
    

}
@end

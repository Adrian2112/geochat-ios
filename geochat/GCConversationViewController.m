//
//  GCConversationViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCConversationViewController.h"
#import "GCConversation.h"
#import "GCMessage.h"
#import "ACPlaceholderTextView.h"
#import <socket.IO/SocketIO.h>
#import <socket.IO/SocketIOPacket.h>
#import "GCAppDelegate.h"
#import "GCMessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <NUI/UIButton+NUI.h>

#define kChatBarHeight4                      94
#define CHAT_BAR_HEIGHT                      40
#define TEXT_VIEW_X                          7   // 40  (with CameraButton)
#define TEXT_VIEW_Y                          2
#define TEXT_VIEW_WIDTH                      249 // 216 (with CameraButton)
#define TEXT_VIEW_HEIGHT_MIN                 90
#define MessageFontSize                      16

#define UIKeyboardNotificationsObserve() \
NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; \
[notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil]
//[notificationCenter addObserver:self selector:@selector(keyboardDidShow:)  name:UIKeyboardDidShowNotification  object:nil]; \
//[notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil]; \
//[notificationCenter addObserver:self selector:@selector(keyboardDidHide:)  name:UIKeyboardDidHideNotification  object:nil]

#define UIKeyboardNotificationsUnobserve() \
[[NSNotificationCenter defaultCenter] removeObserver:self];


@interface GCConversationViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, SocketIODelegate> {
    UIBackgroundTaskIdentifier socketClose;
}

@property (strong, nonatomic) GCConversation *conversation;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ACPlaceholderTextView *textView;
@property (strong, nonatomic) SocketIO *socketIO;

@end


@implementation GCConversationViewController

@synthesize conversation = _conversation;
@synthesize place_id = _place_id;
@synthesize place_name = _place_name;
@synthesize sendButton = _sendButton;
@synthesize tableView = _tableView;
@synthesize textView = _textView;
@synthesize socketIO = _socketIO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.place_name;
    
    self.conversation = [[GCConversation alloc] initWithPlaceId:self.place_id];
    
    
    // taken from AcaniChat https://github.com/acani/AcaniChat
    
    // Create _tableView to display messages.
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-CHAT_BAR_HEIGHT)];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
//    _tableView.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    // Create messageInputBar to contain _textView, messageInputBarBackgroundImageView, & _sendButton.
    UIImageView *messageInputBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-CHAT_BAR_HEIGHT, self.view.frame.size.width, CHAT_BAR_HEIGHT)];

    messageInputBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    messageInputBar.opaque = YES;
    messageInputBar.userInteractionEnabled = YES; // makes subviews tappable
    messageInputBar.image = [[UIImage imageNamed:@"MessageInputBarBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 3, 19, 3)]; // 8 x 40
    
    // Create _textView to compose messages.
    // TODO: Shrink cursor height by 1 px on top & 1 px on bottom.
    _textView = [[ACPlaceholderTextView alloc] initWithFrame:CGRectMake(TEXT_VIEW_X, TEXT_VIEW_Y, TEXT_VIEW_WIDTH, TEXT_VIEW_HEIGHT_MIN)];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor colorWithWhite:245/255.0f alpha:1];
    _textView.scrollIndicatorInsets = UIEdgeInsetsMake(13, 0, 8, 6);
    _textView.scrollsToTop = NO;
    _textView.font = [UIFont systemFontOfSize:MessageFontSize];
    _textView.placeholder = NSLocalizedString(@" Message", nil);
    [messageInputBar addSubview:_textView];
    
    // Create messageInputBarBackgroundImageView as subview of messageInputBar.
    UIImageView *messageInputBarBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MessageInputFieldBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 12, 18, 18)]]; // 32 x 40
    messageInputBarBackgroundImageView.frame = CGRectMake(TEXT_VIEW_X-2, 0, TEXT_VIEW_WIDTH+2, CHAT_BAR_HEIGHT);
    messageInputBarBackgroundImageView.autoresizingMask = self.tableView.autoresizingMask;
    [messageInputBar addSubview:messageInputBarBackgroundImageView];
    
    // Create sendButton.
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.nuiClass = @"none";
    _sendButton.frame = CGRectMake(messageInputBar.frame.size.width-65, 8, 59, 26);
    _sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin /* multiline input */ | UIViewAutoresizingFlexibleLeftMargin /* landscape */);
    UIEdgeInsets sendButtonEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13); // 27 x 27
    UIImage *sendButtonBackgroundImage = [[UIImage imageNamed:@"SendButton"] resizableImageWithCapInsets:sendButtonEdgeInsets];
    [_sendButton setBackgroundImage:sendButtonBackgroundImage forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:sendButtonBackgroundImage forState:UIControlStateDisabled];
    [_sendButton setBackgroundImage:[[UIImage imageNamed:@"SendButtonHighlighted"] resizableImageWithCapInsets:sendButtonEdgeInsets] forState:UIControlStateHighlighted];
    _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_sendButton setTitleShadowColor:[UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [messageInputBar addSubview:_sendButton];
    
    
    [self.view addSubview:messageInputBar];

    if (_conversation.draft) {
        _textView.text = _conversation.draft;
        UIKeyboardNotificationsObserve();
        [_textView becomeFirstResponder];
    } else {
        _sendButton.enabled = NO;
        _sendButton.titleLabel.alpha = 0.5f; // Sam S. says 0.4f
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willEnterForeground:)
                                                 name: @"willEnterForeground"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willResignActive:)
                                                 name: @"willResignActive"
                                               object: nil];
    
    [self reconnect];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIKeyboardNotificationsObserve();
    [_tableView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
    UIKeyboardNotificationsUnobserve(); // as soon as possible
    
    [self disconnect];
    [super viewWillDisappear:animated];
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect frameEnd;
    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];
    
    //    NSLog(@"animationDuration: %f", animationDuration); // TODO: Why 0.35 on viewDidLoad?
    [UIView animateWithDuration:animationDuration delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGFloat viewHeight = [self.view convertRect:frameEnd fromView:nil].origin.y;
        UIView *messageInputBar = _textView.superview;
        
        CGFloat y = viewHeight-messageInputBar.frame.size.height;
        
        UIView *view = messageInputBar;
        view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
        
        _tableView.contentInset = _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.view.frame.size.height-viewHeight, 0);
        [self scrollToBottomAnimated:NO];
    } completion:nil];
}


- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - Save/Send/Receive Messages

- (void)sendMessage {
    
    // Send message.
    GCMessage *message = [[GCMessage alloc] initWithMessage:self.textView.text user:GC_APP_DELEGATE().name photoURL:GC_APP_DELEGATE().photo];
    
    [self addMessageToConversation:message];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[message toDictionary]];
    
    [params setObject:self.place_id forKey:@"place_id"];
    
    [self.socketIO sendEvent:@"new message" withData:params];

    [self scrollToBottomAnimated:YES];
    
//    ACMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"ACMessage" inManagedObjectContext:_managedObjectContext];
//    _conversation.lastMessageSentDate = message.sentDate = [NSDate date];
//    _conversation.lastMessageText = message.text = _textView.text;
//    [_conversation addMessagesObject:message];
    
//    [AC_APP_DELEGATE() sendMessage:message];
    
    _textView.text = nil;
    [self textViewDidChange:_textView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversation.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GCMessageCell";
    
    GCMessageCell *cell = (GCMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCMessageCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    GCMessage *message = self.conversation.messages[indexPath.row];
    
    cell.message.text = message.message;
    cell.date.text = [message createdAtString];
    cell.user.text = message.user;
    NSURL *photo_url = [NSURL URLWithString: message.photoURL ];

    [cell.photo setImageWithURL: photo_url
                   placeholderImage:[UIImage imageNamed:@"default_avatar.gif"]];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCMessageCell" owner:self options:nil];
    GCMessageCell *cell = cell = [nib objectAtIndex:0];

    GCMessage *message = self.conversation.messages[indexPath.row];

    cell.message.text = message.message;
    
    return [cell getHeight];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    // Change height of _tableView & messageInputBar to match textView's content height.
    CGFloat textViewContentHeight = textView.contentSize.height + 4 ;
//    CGFloat changeInHeight = textViewContentHeight; // - _previousTextViewContentHeight;
    
//    if (textViewContentHeight+changeInHeight > 72+2){ //kChatBarHeight4+2) {
//        changeInHeight = 72+2;// kChatBarHeight4+2; //-_previousTextViewContentHeight;
//    }
    UIView *messageInputBar = _textView.superview;
    CGFloat changeInHeight = 0;
    
    if (textViewContentHeight <= 100) {
        changeInHeight = textViewContentHeight - messageInputBar.frame.size.height;
    }
    
    if (changeInHeight) {
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.contentInset = _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, _tableView.contentInset.bottom+changeInHeight, 0);
            [self scrollToBottomAnimated:NO];
            UIView *messageInputBar = _textView.superview;
            messageInputBar.frame = CGRectMake(0, messageInputBar.frame.origin.y-changeInHeight, messageInputBar.frame.size.width, messageInputBar.frame.size.height+changeInHeight);
        } completion:^(BOOL finished) {
            [_textView updateShouldDrawPlaceholder];
        }];
//        _previousTextViewContentHeight = MIN(textViewContentHeight, kChatBarHeight4+2);
    }
    
    // Enable/disable sendButton if textView.text has/lacks length.
    if ([textView.text length]) {
        _sendButton.enabled = YES;
        _sendButton.titleLabel.alpha = 1;
    } else {
        _sendButton.enabled = NO;
        _sendButton.titleLabel.alpha = 0.5f; // Sam S. says 0.4f
    }
}

# pragma mark - AppDelegate Notifications

-(void) willEnterForeground:(NSNotification *)notification{
    [self reconnect];
}

-(void) willResignActive:(NSNotification *)notification{
    // Start long-running background task
    UIBackgroundTaskIdentifier bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];

    NSLog(@"resign");
    [self disconnect];
}

-(void) disconnect{
    NSLog(@"self disconnect");
    socketClose = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    [self.socketIO disconnect];
}

-(void) reconnect{
    NSLog(@"reconnect");
    
    self.socketIO = nil;
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    // Connect to place_id namespace
    [self.socketIO connectToHost:HOST onPort:PORT];
}

# pragma mark SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket{
    NSDictionary *request_messages = @{@"room": self.place_id, @"access_token": GC_APP_DELEGATE().accessToken};

    [self.socketIO sendEvent:@"join room" withData:request_messages];
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    NSLog(@"%@", error);
    [[UIApplication sharedApplication] endBackgroundTask:socketClose];
//    _webSocket.delegate = nil;
//    _webSocket = nil;
//    _messagesSending = nil;
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet{
    
    NSDictionary *json = [packet dataAsJSON];
//    NSLog(@"%@", json);
    
    NSString *message_type = json[@"name"];
    
    if ([message_type isEqualToString:@"new message"]) {
        NSDictionary *json_message = json[@"args"][0][@"messages"][0];
//        NSLog(@"messages: %@", json_message);
        
        GCMessage *message = [[GCMessage alloc] initWithDictionary:json_message];
        
        [self addMessageToConversation:message];
    } else if ([message_type isEqualToString:@"init messages"]) {
        NSArray *json_messages = json[@"args"][0][@"messages"];
//        NSLog(@"messages: %@", json_messages);
        
        [self.conversation initializeMessagesWithMessagesArray:json_messages];
        [self.tableView reloadData];
        [self scrollToBottomAnimated:NO];
        
    }
}


-(void) addMessageToConversation:(GCMessage *)message{
    [self.conversation addMessage:message];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}


@end
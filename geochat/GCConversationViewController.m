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


@interface GCConversationViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) GCConversation *conversation;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ACPlaceholderTextView *textView;

@end


@implementation GCConversationViewController

@synthesize conversation = _conversation;
@synthesize place_id = _place_id;
@synthesize place_name = _place_name;
@synthesize sendButton = _sendButton;
@synthesize tableView = _tableView;
@synthesize textView = _textView;

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
//    [_sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [UIView animateWithDuration:animationDuration delay:0.0 options:(UIViewAnimationOptionsFromCurve(animationCurve) | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGFloat viewHeight = [self.view convertRect:frameEnd fromView:nil].origin.y;
        UIView *messageInputBar = _textView.superview;
        UIViewSetFrameY(messageInputBar, viewHeight-messageInputBar.frame.size.height);
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GCMessage *message = self.conversation.messages[indexPath.row];
    
    cell.textLabel.text = message.message;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

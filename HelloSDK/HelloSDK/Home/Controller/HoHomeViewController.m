//
//  HoHomeViewController.m
//  HelloSDK
//
//  Created by AAA on 10/4/2022.
//

#import "HoHomeViewController.h"
#import <Masonry/Masonry.h>

@interface HoHomeViewController ()
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation HoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSString *helloBundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"hello" ofType:@"bundle"];
    NSBundle *helloBoundle = [NSBundle bundleWithPath:helloBundlePath];
    UIImage *hands = [[UIImage alloc] initWithContentsOfFile:[helloBoundle pathForResource:@"hands" ofType:@"jpeg"]];
    self.imageView = [[UIImageView alloc] initWithImage:hands];
    [self.view addSubview:self.imageView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

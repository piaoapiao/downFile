//
//  ViewController.m
//  Animusic
//
//  Created by sban@netspectrum.com on 9/21/12.
//  Copyright (c) 2012 Netspectrum Inc. All rights reserved.
//

#import "ViewController.h"
#import "AFDownloadRequestOperation.h"
#import "ZipArchive.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define MUSICFile [DocumentsDirectory stringByAppendingPathComponent:@"test.mov"]
#define MUSICFile2 [DocumentsDirectory stringByAppendingPathComponent:@"test2.mov"]

#define MUSICFolder [DocumentsDirectory stringByAppendingPathComponent:@"testFoler"]
#define MUSICFolder2 [DocumentsDirectory stringByAppendingPathComponent:@"testFoler2"]

@interface ViewController ()
@property (nonatomic,strong) IBOutlet UILabel *progressLabel;
@property (nonatomic,strong) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong) IBOutlet UIButton *downloadBtn;
@property (nonatomic,strong) IBOutlet UIButton *playBtn;
@property (nonatomic,strong) IBOutlet UILabel *currentSizeLabel;
@property (nonatomic,strong) IBOutlet UILabel *totalSizeLabel;


- (IBAction)beginDownload:(id)sender;
- (IBAction)beginPlay:(id)sender;
@end

@implementation ViewController
@synthesize progressLabel,progressView,downloadBtn,playBtn;
@synthesize currentSizeLabel,totalSizeLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.currentSizeLabel.text = @"CUR : 0 M";
    self.totalSizeLabel.text = @"TOTAL : 0 M";
    self.view.layer.cornerRadius = 5;
    
    proView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 20, 280, 20)];
    [self.view addSubview:proView];
    
    quene = [[NSOperationQueue alloc] init];
    quene.maxConcurrentOperationCount = 1;

    self.view.backgroundColor = [UIColor colorWithRed:217/255. green:218/255. blue:219/255. alpha:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)beginDownload:(id)sender{
    NSString *urlStr = @"http://jsyd.xiazaiba.com/Soft/O/OllyDbg_2.01_alpha4_XiaZaiBa.zip";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:MUSICFile shouldResume:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", MUSICFile);
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testFolder" ofType:nil];
        
        //  filePath = MUSICFile;
        BOOL result;
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile:MUSICFolder]) {
            result = [za UnzipFileTo:MUSICFolder overWrite:YES];
            [za UnzipCloseFile];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
        
        self.progressView.progress = percentDone;
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",percentDone*100];
        
        self.currentSizeLabel.text = [NSString stringWithFormat:@"CUR : %lli M",totalBytesReadForFile/1024/1024];
        self.totalSizeLabel.text = [NSString stringWithFormat:@"TOTAL : %lli M",totalBytesExpectedToReadForFile/1024/1024];

        NSLog(@"------%f",percentDone);
        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
    }];
//    [operation start];
 //   [quene addOperations:<#(NSArray *)#> waitUntilFinished:<#(BOOL)#>:operation];
    
//    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:operation, nil];
//    [quene addOperations:arr waitUntilFinished:YES];
    [quene addOperation:operation];
}

- (IBAction)beginPlay:(id)sender{
//    AudioPlayer *player = [AudioPlayer sharePlayer];
//    [player playWithDataSourceType:DataSourceTypeLocal withURLString:MUSICFile];
//    MPMoviePlayerViewController *MPC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:MUSICFile]];
//
//    MPMoviePlayerController *moviePlayer = MPC.moviePlayer;
//    moviePlayer.repeatMode = MPMovieRepeatModeNone;
//    moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
//    [self presentMoviePlayerViewControllerAnimated:MPC];
    
    NSString *urlStr = @"http://jsyd.xiazaiba.com/Soft/J/jpwb_7.0_XiaZaiBa.exe";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:MUSICFile2 shouldResume:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", MUSICFile);
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testFolder" ofType:nil];
        
        //  filePath = MUSICFile;
        BOOL result;
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile:MUSICFile2]) {
            result = [za UnzipFileTo:MUSICFolder2 overWrite:YES];
            [za UnzipCloseFile];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
        
       proView.progress = percentDone;
//        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",percentDone*100];
//        
//        self.currentSizeLabel.text = [NSString stringWithFormat:@"CUR : %lli M",totalBytesReadForFile/1024/1024];
//        self.totalSizeLabel.text = [NSString stringWithFormat:@"TOTAL : %lli M",totalBytesExpectedToReadForFile/1024/1024];
        
        NSLog(@"------%f",percentDone);
//        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
//        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
//        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
//        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
//        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
    }];
        [quene addOperation:operation];
//    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:operation, nil];
//    [quene addOperations:arr waitUntilFinished:YES];
    //[operation start];
    
}
@end

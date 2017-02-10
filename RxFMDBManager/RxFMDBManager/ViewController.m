//
//  ViewController.m
//  RxFMDBManager
//
//  Created by RXL on 17/2/8.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import "ViewController.h"

#define studentTable @"t_students"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *nameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *fixBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *studentsArr;
@property (nonatomic, strong) FMDBManager *dataBaseManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加入初始化数据
    NSArray *studentArr = @[
                            @{@"name":@"Lili",@"userId":@"1"},
                            @{@"name":@"Ted",@"userId":@"2"},
                            @{@"name":@"Jack",@"userId":@"3"},
                            @{@"name":@"Rose",@"userId":@"4"},
                            @{@"name":@"Lucy",@"userId":@"5"},
                            @{@"name":@"Bob",@"userId":@"6"}
                            ];

    
    [self.dataBaseManager addStudentWithJsonArr:studentArr WithCompletion:^(NSError *error) {
        
        if (error) {
            
            [SVProgressHUD showErrorWithStatus:@"插入失败"];
            
        }else{
            
            [SVProgressHUD showSuccessWithStatus:@"插入成功"];
            
        }
    }];
    
}
- (IBAction)hiddenKeyBoard:(id)sender {
    [self.view endEditing:YES];
}
#pragma mark - 数据库操作
- (IBAction)addBtnClick:(id)sender {
    
    //检查数据的合法性
    if (self.nameTextFiled.text.length && self.userIDTextFiled.text.length) {
     
        [self.dataBaseManager addStudentWithJsonArr:@[@{@"name":self.nameTextFiled.text,@"userId":self.userIDTextFiled.text}] WithCompletion:^(NSError *error) {
            
            if (!error) {
                //刷新列表
                [SVProgressHUD showSuccessWithStatus:@"插入成功"];
                
                
            }else{
                [SVProgressHUD showErrorWithStatus:@"插入失败,检查userId是否重复"];
            }
            
        }];
        
    }
}
- (IBAction)deleteBtnClick:(id)sender {
}
- (IBAction)fixBtnClick:(id)sender {
}
- (IBAction)selectBtnClick:(id)sender {
    
    
}


#pragma mark - 數據源及代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"fmdb";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }

    
    return cell;
}



#pragma mark - 懒加载
-(NSMutableArray *)studentsArr{
    if (_studentsArr == nil) {
        _studentsArr = [NSMutableArray array];
    }
    return _studentsArr;
}
-(FMDBManager *)dataBaseManager{
    return [FMDBManager sharedFMDBManager];
}

@end

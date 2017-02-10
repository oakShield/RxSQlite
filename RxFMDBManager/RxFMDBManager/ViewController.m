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
@property (nonatomic, weak) IBOutlet UITextField *selectContionTextFiled;
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
    
    //查询本地数据

    
}
- (IBAction)hiddenKeyBoard:(id)sender {
    [self.view endEditing:YES];
}
#pragma mark - 数据库操作
- (IBAction)addBtnClick:(id)sender {
    
    //检查数据的合法性
    if (self.nameTextFiled.text.length && self.userIDTextFiled.text.length) {
     
        [self.dataBaseManager executeUpdateWithJsonArr:@[@{@"name":self.nameTextFiled.text,@"userId":self.userIDTextFiled.text}] WithCompletion:^(NSError *error) {
            
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

    NSArray *resultArr = [self.dataBaseManager executeStudentWithCondition:self.selectContionTextFiled.text FromTable:studentTable];
    
    if (resultArr.count) {
        
        [SVProgressHUD showErrorWithStatus:@"未查到"];
        
    }else{
        
        [self.studentsArr removeAllObjects];
        
        [self.studentsArr addObjectsFromArray:resultArr];
        
        [self.tableView reloadData];
    }
}



#pragma mark - 數據源及代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.studentsArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"fmdb";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    RxStudentModel *model = self.studentsArr[indexPath.row];
    
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.userId;
    
    return cell;
}

#pragma mark - 自定义方法

-(NSMutableArray *)StudentJsonRevertToModelWith:(NSArray *)jsonArr{
    
    NSMutableArray *modelArr = [NSMutableArray arrayWithCapacity:jsonArr.count];
    
    for (NSDictionary *dict in jsonArr) {
        
        RxStudentModel *model = [RxStudentModel mj_objectWithKeyValues:dict];
        
        [modelArr addObject:model];
        
    }
    
    return modelArr;
}


-(void)prepareData{
    NSArray *studentArr = @[
                            @{@"name":@"Lili",@"userId":@"1"},
                            @{@"name":@"Ted" ,@"userId":@"2"},
                            @{@"name":@"Jack",@"userId":@"3"},
                            @{@"name":@"Rose",@"userId":@"4"},
                            @{@"name":@"Lucy",@"userId":@"5"},
                            @{@"name":@"Bob7" ,@"userId":@"6"},
                            @{@"name":@"Bili" ,@"userId":@"7"}
                            ];
    
    
    [self.dataBaseManager executeUpdateWithJsonArr:studentArr WithCompletion:^(NSError *error) {
        
        if (error) {
            
            [SVProgressHUD showErrorWithStatus:@"插入失败"];
            
        }else{
            
            [SVProgressHUD showSuccessWithStatus:@"插入成功"];
            
        }
    }];
}

#pragma mark - 懒加载
-(NSMutableArray *)studentsArr{
    if (_studentsArr == nil) {
        NSArray *jsonarr = [[self.dataBaseManager executeAllStudentFrom:studentTable] copy];
        _studentsArr = [self StudentJsonRevertToModelWith:jsonarr];
    }
    return _studentsArr;
}
-(FMDBManager *)dataBaseManager{
    return [FMDBManager sharedFMDBManager];
}



@end

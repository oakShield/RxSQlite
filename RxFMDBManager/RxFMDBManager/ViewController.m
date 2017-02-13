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
@property (weak, nonatomic) IBOutlet UITextField *fixUserIdTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *anthorNameTextFiled;

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
                
                RxStudentModel *model = [[RxStudentModel alloc] init];
                
                model.name = self.nameTextFiled.text;
                
                model.userId = self.userIDTextFiled.text;
                
                [self.studentsArr addObject:model];
                
                [self.tableView reloadData];
                
                
            }else{
                [SVProgressHUD showErrorWithStatus:@"插入失败,检查userId是否重复"];
            }
            
        }];
        
    }
}
- (IBAction)deleteBtnClick:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES] ;
}
- (IBAction)fixBtnClick:(id)sender {
    
    if (!self.fixUserIdTextFiled.text.length && !self.anthorNameTextFiled.text.length) {
        
        [SVProgressHUD showErrorWithStatus:@"请填写信息"];
        
        return;
    }
    
    //改
    [self.dataBaseManager executeFixWithCondition:self.fixUserIdTextFiled.text ToNewName:self.anthorNameTextFiled.text FromTable:studentTable WithCompletion:^(NSError *error) {
        
        if (error) {
            
            [SVProgressHUD showErrorWithStatus:@"失败,请检查是否存在"];
            
        }else{
            
            [SVProgressHUD showSuccessWithStatus:@"成功"];
            
            NSInteger row =[self fixValueWhere:self.fixUserIdTextFiled.text SetNewName:self.anthorNameTextFiled.text];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
    
}

//修改数据中的数据
-(NSInteger)fixValueWhere:(NSString *)userId SetNewName:(NSString *)newName{
    
    NSInteger index = 0;
    
    for (RxStudentModel *model in self.studentsArr) {
        
        if ([userId isEqualToString:model.userId]) {
            
            model.name = newName;
            
            break;
        }
        
    }
    
    return index;
}

- (IBAction)selectBtnClick:(id)sender {

    NSArray *resultArr = [self.dataBaseManager executeStudentWithCondition:self.selectContionTextFiled.text FromTable:studentTable];
    
    if (!resultArr.count) {
        
        [SVProgressHUD showErrorWithStatus:@"未查到"];
        
    }else{
        
        [SVProgressHUD showSuccessWithStatus:@"已经查到"];
        
        [self.studentsArr removeAllObjects];
        
        self.studentsArr = [self StudentJsonRevertToModelWith:resultArr];
        
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //从数据源删除此数据
    RxStudentModel *model = self.studentsArr[indexPath.row];
    
    [self.studentsArr removeObjectAtIndex:indexPath.row];
    
    //从数据库删除数据
    
    NSString *userId = model.userId;
    
    [self.dataBaseManager executeDeleteWithCondition:userId FromTable:studentTable];
    
    //刷新界面
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}



/**
 *  返回indexPath对应的编辑样式
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.editing) {
        
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
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

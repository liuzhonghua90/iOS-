//
//  SettingMainViewController.m
//  iFaceDemo
//
//  Created by LIANGKUNLIN on 16/7/4.
//  Copyright © 2016年 meilixun. All rights reserved.
//

#import "SettingMainViewController.h"
#import "EMSBLEManager.h"
#import "BLEUtility.h"

@interface SettingMainViewController ()<EMSBLEManagerDelegate>


/**
 *  状态
 */
@property (weak, nonatomic) IBOutlet UILabel *connectStateLb;

@property (nonatomic,strong) EMSBLEManager * m_BLEManager;
@property (nonatomic,strong) NSMutableArray * dataArray;

@property (nonatomic, assign) int stateNum;//运行状态参数
@property (nonatomic, assign) int powerNum;//功率参数
@property (nonatomic, assign) int colorNum;//灯光参数
@property (nonatomic, assign) int powerstate;//电流状态
@property (nonatomic, copy) NSString *data;
@end

@implementation SettingMainViewController

-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


-(void)viewWillAppear:(BOOL)animated{
    self.m_BLEManager=[EMSBLEManager shareBLEManager];
    [EMSBLEManager shareBLEManager].delegate=self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (CGRectGetMaxY(self.postLb.frame)>[UIScreen mainScreen].bounds.size.height) {
        self.scv.contentSize = CGSizeMake(0, CGRectGetMaxY(self.postLb.frame)+180);
    }else{
        self.scv.contentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height+1);
    }
    self.scv.scrollEnabled = YES;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
   [self.m_BLEManager scan];
    self.connectStateLb.text = @"未连接";
    self.connectStateLb.textColor = [UIColor grayColor];
    [self.connectBtn setTitle:@"正在搜索外部设备……" forState:UIControlStateNormal];
    [self.connectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.connectBtn.enabled = NO;
    
    

    if ([EMSBLEManager shareBLEManager].periphearlArray.count >0) {
        [EMSBLEManager shareBLEManager].m_peripheral = [[EMSBLEManager shareBLEManager].periphearlArray objectAtIndex:0];
        [[EMSBLEManager shareBLEManager].m_centralManager connectPeripheral:[EMSBLEManager shareBLEManager].m_peripheral options:nil];
        [[EMSBLEManager shareBLEManager] clean];
    }
    //初始化默认值 、
    self.stateNum = 1;//开机－－1
    self.powerNum = 1;//功率--1
    self.colorNum = 0;//灯光－－关灯
    
    //发送数据
    self.postLb.text = [NSString stringWithFormat:@"运行模式：%d 功率：%d 灯光：%d 电流状态：%d",self.stateNum,self.powerNum,self.colorNum,self.powerstate];
    
}

#pragma mark -返回接受的数据
-(void)BLEGetData:(CBPeripheral *)peripheral dataString:(NSString *)string
{
    self.data = string;
    //接受数据
    self.recieveLb.text = [NSString stringWithFormat:@"%@",self.data];
}
#pragma mark - 获取到电流状态
-(void)BLEGetInfo:(CBPeripheral *)peripheral powerState:(int)powerState
{
    self.powerstate = powerState;
}
#pragma mark - 写入运行状态、功率、灯光、电流状态
-(void)writeColorDataWithStateNum:(int)stateNum powerNum:(int)powerNum colorNum:(int)colorNum powerState:(int)powerState
{
    //发送指令
    
    uint8_t requestData[9] ={0};
    requestData[0] =0xff;//固定
    requestData[1] =stateNum &0xff;//运行状态
    requestData[2] =powerNum &0xff;//功率
    requestData[3] =colorNum &0xff;//灯光
    requestData[4] =powerState &0xff;//电流状态
    requestData[5] =0xcc;
    requestData[6] =0x33;
    requestData[7] =0xc3;
    requestData[8] =0x3c;
    
    
    if ([EMSBLEManager shareBLEManager].m_peripheral != nil) {
        
        [BLEUtility writeCharacteristic:[EMSBLEManager shareBLEManager].m_peripheral sUUID:@"fff0" cUUID:@"fff4" data:[NSData dataWithBytes:&requestData length:10]];
    }
}



//红光
- (IBAction)redBtnClick:(id)sender {
    
    //发送红光指令
    self.colorNum = 1;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
    
}


- (IBAction)greenBtnClick:(id)sender {
    
    //发送绿光指令
    self.colorNum = 2;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}



- (IBAction)blueBtnClick:(id)sender {
    
    //发送蓝光指令
    self.colorNum = 3;
   [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}


- (IBAction)yellowBtnClick:(id)sender {
    
    //发送黄光指令
    self.colorNum = 4;
   [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}

- (IBAction)pinkBtnClick:(id)sender {
    
    //发送红蓝光指令
    self.colorNum = 5;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}



- (IBAction)purpleBtnClick:(id)sender {
    
    //发送紫光闪烁光指令
    self.colorNum = 6;
   [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}


- (IBAction)closedLEDBtnClick:(id)sender {
    
    //关闭LED光指令
    self.colorNum = 0;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
    
}

- (IBAction)stopBtnClick:(id)sender {
    
    //暂停指令
    self.stateNum = 2;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}

- (IBAction)resetBtnClick:(id)sender {
    //重新开始指令
    self.stateNum = 1;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}

- (IBAction)offBtnClick:(id)sender {
    
    //关机指令
    self.stateNum = 0;
    [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
}

- (IBAction)reduceBtnClick:(id)sender {
    

    self.powerNum = [self.powerCountLb.text intValue];
    
    if (self.powerNum>1 && self.powerNum<=5) {
        self.powerNum-- ;
        [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
        self.powerCountLb.text = [NSString stringWithFormat:@"%d",self.powerNum];
    }
    
}

- (IBAction)plusBtnClick:(id)sender {
    
    self.powerNum = [self.powerCountLb.text intValue];
    
    if (self.powerNum>=1 && self.powerNum<5) {
        self.powerNum++ ;
        [self writeColorDataWithStateNum:self.stateNum powerNum:self.powerNum colorNum:self.colorNum powerState:self.powerstate];
        self.powerCountLb.text = [NSString stringWithFormat:@"%d",self.powerNum];
    }
}


- (IBAction)connectClick:(id)sender {

    if ([EMSBLEManager shareBLEManager].periphearlArray.count > 0) {
        [EMSBLEManager shareBLEManager].m_peripheral = [[EMSBLEManager shareBLEManager].periphearlArray objectAtIndex:0];
        [[EMSBLEManager shareBLEManager].m_centralManager connectPeripheral:[EMSBLEManager shareBLEManager].m_peripheral options:nil];
        [[EMSBLEManager shareBLEManager] clean];
        self.connectBtn.selected = NO;
    }
    
}


#pragma mark -找到硬件的服务和特征
-(void)BLEDiscoverPeripherarl:(CBPeripheral *)periphearl
{
    [self.connectBtn setTitle:@"点我链接硬件" forState:UIControlStateNormal];
    [self.connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.connectBtn.enabled = YES;
    [self.dataArray addObject:periphearl];
}

-(void)BLEConnectedPeriphearl:(CBPeripheral *)peripheral{
    self.connectStateLb.text = @"已连接";
    self.connectStateLb.textColor = [UIColor blackColor];
    [[EMSBLEManager shareBLEManager] stop];
    [self.connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectBtn setTitle:@"点我链接硬件" forState:UIControlStateNormal];
    self.connectBtn.enabled = NO;
    

}

-(void)BLEDisconnectedPeripheral:(CBPeripheral *)peripheral{
    self.connectStateLb.text = @"未连接";
    [self.connectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.connectBtn setTitle:@"硬件搜索失败" forState:UIControlStateNormal];
    self.connectBtn.enabled = NO;
}


-(void)dealloc
{
    [[EMSBLEManager shareBLEManager] clean];
}


@end

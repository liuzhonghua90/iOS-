//
//  EMSBLEManager.m
//  EMSDemo
//
//  Created by LIANGKUNLIN on 16/7/13.
//  Copyright © 2016年 meilixun. All rights reserved.
//

#import "EMSBLEManager.h"
#import "BLEUtility.h"
#import "AppDelegate.h"

@interface EMSBLEManager()
{
    BOOL isSelected;
}
@end
@implementation EMSBLEManager
static EMSBLEManager * instance = nil;
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnsupported:
            NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
            break;
            
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"BLE已打开.");
            [self scan];
            
        }
            break;
        default:
        {
            
            NSLog(@"BLE未打开.");
            
        }
            break;
    }
}


+(EMSBLEManager*)shareBLEManager;//单例的初始化方法，有很多种，但是这个是苹果官方推荐的。
{
    static EMSBLEManager *timemanageInstance=nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        timemanageInstance=[[self alloc]init];
    });
    return  timemanageInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        _m_centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        _periphearlArray = [[NSMutableArray alloc]init];
        _identifierArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)clean{
    [self.periphearlArray removeAllObjects];
    [self.identifierArray removeAllObjects];
}

-(void)stop{
    [_m_centralManager stopScan];
}

#pragma mark -检测蓝牙
-(void)scan{
    NSArray * services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFF0"], nil];
    [_m_centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

#pragma mark - 扫描到蓝牙设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"已发现 BLE 设备 : peripheral: %@",peripheral);
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    if ([localName isEqualToString:@"iUart"]||[peripheral.name isEqualToString:@"iUart"]) {
        if ([_identifierArray indexOfObject:[peripheral.identifier UUIDString]]==NSNotFound) {
            [_identifierArray addObject:[peripheral.identifier UUIDString]];
            [_periphearlArray addObject:peripheral];
            if ([self.delegate respondsToSelector:@selector(BLEDiscoverPeripherarl:)]) {
                [self.delegate BLEDiscoverPeripherarl:peripheral];
            }
        }
    }
    //一旦扫描到硬件就停止扫描
    [_m_centralManager stopScan];
}

#pragma mark - 蓝牙连接上代理方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.m_peripheral=peripheral;
    self.m_peripheral.delegate=self;
    if ([self.delegate respondsToSelector:@selector(BLEConnectedPeriphearl:)]) {
        [self.delegate BLEConnectedPeriphearl:peripheral];
    }
    [peripheral discoverServices:nil];
    
    //连接上蓝牙后每隔一秒发送一条查询指令
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSTimer *timer = app.timer;
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(select) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark - 蓝牙断掉代理方法
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(BLEDisconnectedPeripheral:)]) {
        [self.delegate BLEConnectedPeriphearl:peripheral];
    }
}

-(void)select
{
    //每隔一秒发送查询指令
    
    uint8_t requestData[9] ={0};
    requestData[0] =0xff;
    requestData[1] =0x03;
    requestData[2] =0x00;
    requestData[3] =0x00;
    requestData[4] =0x00;
    requestData[5] =0xcc;
    requestData[6] =0x33;
    requestData[7] =0xc3;
    requestData[8] =0x3c;
    
    [BLEUtility writeCharacteristic:[EMSBLEManager shareBLEManager].m_peripheral sUUID:@"fff0" cUUID:@"fff4" data:[NSData dataWithBytes:&requestData length:10]];
}
#pragma mark - 发现蓝牙服务的代理方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到的服务有-----peripheral.services = %@",peripheral.services);
    for (CBService *service in [peripheral services]) {
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"fff1"],[CBUUID UUIDWithString:@"fff2"],[CBUUID UUIDWithString:@"fff3"],[CBUUID UUIDWithString:@"fff4"],[CBUUID UUIDWithString:@"fff5"],] forService:service];
        
    }
}

#pragma mark - 蓝牙发现特征的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    
    NSLog(@"特征有%@--------%@",[peripheral.identifier UUIDString],service.characteristics);
    
    
    //检查特性
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //1.操作通知和返回接口
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"fff3"]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        }
        
    }
    
    
}

#pragma mark - 蓝牙发送指令成功或者失败代理方法
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (!error) {
        NSLog(@"说明发送成功,characteristic.uuid为：%@ ＝＝%@",characteristic.value,[characteristic.UUID UUIDString]);
        
    }else{
        NSLog(@"发送失败了啊！characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
    }
    
}

#pragma mark - 蓝牙返回数据的代理方法
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"fff3"]]) {
        Byte *characByte = (Byte *)[characteristic.value bytes];
        
        if (characByte[0] == 0xff) {
            
            NSString *hexStr = @"";
            for (int i = 0; i < 5; i++) {
                NSString *newHexStr = [NSString stringWithFormat:@"%x",characByte[5]&0xff];
                if ([newHexStr length]==1) {
                    hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                }else{
                    hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
                }
            }
           
            // 返回5位的数据
            if ([_delegate respondsToSelector:@selector(BLEGetData:dataString:)]) {
                [_delegate BLEGetData:peripheral dataString:hexStr];
            }
            
            int value = (int)(characByte[4] & 0xff);
            //返回电流状态
            if ([_delegate respondsToSelector:@selector(BLEGetInfo:powerState:)]) {
                [_delegate BLEGetInfo:peripheral powerState:value];
            }
            
    
        }
        
    }
    
}

@end

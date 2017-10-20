//
//  EMSBLEManager.h
//  EMSDemo
//
//  Created by LIANGKUNLIN on 16/7/13.
//  Copyright © 2016年 meilixun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol EMSBLEManagerDelegate <NSObject>

@optional

-(void)BLEDiscoverPeripherarl:(CBPeripheral *)periphearl;
-(void)BLEConnectedPeriphearl:(CBPeripheral *)peripheral;
-(void)BLEDisconnectedPeripheral:(CBPeripheral *)peripheral;
-(void)BLEGetData:(CBPeripheral *)peripheral dataString:(NSString *)string;
-(void)BLEGetInfo:(CBPeripheral *)peripheral powerState:(int)powerState;

@end

@interface EMSBLEManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) CBCentralManager * m_centralManager;
@property (nonatomic,strong) CBPeripheral * m_peripheral;


@property (nonatomic,strong) NSMutableArray * periphearlArray;
@property (nonatomic,strong) NSMutableArray * identifierArray;
@property (strong , nonatomic) id<EMSBLEManagerDelegate>delegate;


+(EMSBLEManager *)shareBLEManager;

-(void)scan;
-(void)clean;
-(void)stop;


@end

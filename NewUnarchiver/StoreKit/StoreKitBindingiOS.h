//
//  StoreKitBindingiOS.h
//  Demolition M
//
//  Created by Sergei Merenkov on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@class StoreKitBindingiOS;

@protocol StoreKitBindingDelegate <NSObject>

@required

-(void)storeKit:(StoreKitBindingiOS*)_storeKit getProducts:(NSString*)products;
-(void)storeKit:(StoreKitBindingiOS*)_storeKit productPurchased:(NSString*)product;


//@optional
-(void)storeKit:(StoreKitBindingiOS*)_storeKit productCanceled:(NSString*)product;

//KOVAL: для скрытия MBProgressHUD в случае ошибок или отмены
-(void)storeKit:(StoreKitBindingiOS*)_storeKit failWithError:(NSError*)error;
@end


@interface StoreKitBindingiOS : NSObject{
    NSObject<StoreKitBindingDelegate> *delegate;
}

+ (StoreKitBindingiOS*)sharedManager;

-(void)setDelegate:(NSObject<StoreKitBindingDelegate>*)_delegate;
-(BOOL)canMakePayments;

// Accepts comma-delimited set of product identifiers
-(void)requestProductData:(NSString*)productIdentifiers;
-(void)purchaseProduct:(NSString*)product quantity:(NSInteger)quantity;
- (void)restoreCompletedTransactions;
@end


//
//  StoreKitManager.h
//  StoreKit
//
//  Created by Mike DeSaro on 8/18/10.
//  Copyright 2010 Prime31 Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "StoreKitReceiptRequest.h"
#import "StoreKitBindingiOS.h"

@interface StoreKitManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, StoreKitReceiptRequestDelegate>
{
    NSObject<StoreKitBindingDelegate> *delegate;
}

+ (StoreKitManager*)sharedManager;


- (BOOL)canMakePayments;

- (void)restoreCompletedTransactions;

- (void)requestProductData:(NSSet*)productIdentifiers;

- (void)purchaseProduct:(NSString*)productIdentifier quantity:(int)quantity;

- (void)validateReceipt:(NSString*)transactionReceipt isTestReceipt:(BOOL)isTest;

- (void)validateAutoRenewableReceipt:(NSString*)transactionReceipt withSecret:(NSString*)sharedSecret isTestReceipt:(BOOL)isTest;

- (NSString*)getAllSavedTransactions;

#pragma mark MERENKOFF
#pragma mark -
#pragma mark DELEGATED from C#
-(void)setProductsReceivedDelegate:(void(*)(const char*))nameOfVoid;
-(void)setProductPurchaseResult:(void(*)(const char*,const char*))nameOfVoid;

#pragma mark Delegated from OBJ-C
-(void)setDelegateiOS:(NSObject<StoreKitBindingDelegate>*)_delegate;
@end

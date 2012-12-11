//
//  StoreKitBindingiOS.m
//  Demolition M
//
//  Created by Sergei Merenkov on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreKitBindingiOS.h"
#import "StoreKitManager.h"


@implementation StoreKitBindingiOS

+ (StoreKitBindingiOS*)sharedManager
{
	static StoreKitBindingiOS *sharedManager = nil;
	
	if( !sharedManager )
		sharedManager = [[StoreKitBindingiOS alloc] init];
	
	return sharedManager;
}

-(void)setDelegate:(NSObject<StoreKitBindingDelegate>*)_delegate{
    delegate = _delegate;
}

-(BOOL)canMakePayments{
	return ( [[StoreKitManager sharedManager] canMakePayments] == 1 );
}

// Accepts comma-delimited set of product identifiers
-(void)requestProductData:(NSString*)productIdentifiers{
//    NSString *identifiers = GetStringParam( productIdentifiers );
    //    //NSString *identifiers = @"com.tapmobile.ironwars.test,test,IW_1_100IB,IW_2_900IB,com.tapmobile.ironwars.IW_1_400IB";
	
	NSArray *parts = [productIdentifiers componentsSeparatedByString:@","];
	NSMutableSet *set = [NSMutableSet set];
	
	// add all the products to the set
	for( NSString *product in parts )
		[set addObject:[product stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	
	NSLog(@"%@", [set description]);
	
    
    [[StoreKitManager sharedManager] setDelegateiOS:delegate];
	[[StoreKitManager sharedManager] requestProductData:set];
}

-(void)purchaseProduct:(NSString*)product quantity:(NSInteger)quantity{
    [[StoreKitManager sharedManager] setDelegateiOS:delegate]; 
	[[StoreKitManager sharedManager] purchaseProduct:product quantity:quantity];
}

-(void)restoreCompletedTransactions{
    [[StoreKitManager sharedManager] setDelegateiOS:delegate]; 
	[[StoreKitManager sharedManager] restoreCompletedTransactions];
}

@end

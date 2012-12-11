//
//  StoreKitManager.m
//  StoreKit
//
//  Created by Mike DeSaro on 8/18/10.
//  Copyright 2010 Prime31 Studios. All rights reserved.
//

#import "StoreKitManager.h"
#import "SKPluginTransaction.h"
#import "NSDataBase64.h"

#define UnitySendMessage NSLog
//void UnitySendMessage( const char * className, const char * methodName, const char * param );


@implementation StoreKitManager

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject

+ (StoreKitManager*)sharedManager
{
	static StoreKitManager *sharedManager = nil;
	
	if( !sharedManager )
		sharedManager = [[StoreKitManager alloc] init];
	
	return sharedManager;
}


- (id)init
{
	if( ( self = [super init] ) )
	{
		// Listen to transaction changes
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
static void(*productPurchaseResult)(const char *rezultString, const char *productString);

-(void)setProductPurchaseResult:(void(*)(const char*,const char*))nameOfVoid{
    productPurchaseResult = nameOfVoid;
}

- (void)completeAndRecordTransaction:(SKPaymentTransaction*)transaction
{
	NSLog( @"StoreKit: transaction completed: %@", transaction );
	
	SKPaymentTransaction *transactionToRemove = transaction;
	
	// record the transaction after normalizing restored transactions
	if( transaction.originalTransaction )
		transaction = transaction.originalTransaction;
	
	// extract the transaction details
	NSString *productIdentifier = transaction.payment.productIdentifier;
	NSString *base64EncodedReceipt = nil;//[transaction.transactionReceipt base64Encoding];
	
	// create a pluginTransaction to save to disk
	SKPluginTransaction *pluginTransaction = [[SKPluginTransaction alloc] init];
	pluginTransaction.base64EncodedReceipt = base64EncodedReceipt;
	pluginTransaction.productIdentifier = productIdentifier;
	pluginTransaction.quantity = transaction.payment.quantity;
	[SKPluginTransaction saveTransaction:pluginTransaction];
	[pluginTransaction release];
	
	// complete the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction:transactionToRemove];
	
	// notify Unity
	NSString *returnValue = [NSString stringWithFormat:@"%@|||%@|||%i", productIdentifier, base64EncodedReceipt, transaction.payment.quantity];
    //productPurchaseResult("productPurchased", [returnValue UTF8String]);
    
    [delegate storeKit:nil productPurchased:returnValue];
    
    //	UnitySendMessage( "StoreKitManager", "productPurchased", [returnValue UTF8String] );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public

- (void)requestProductData:(NSSet*)productIdentifiers
{
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	request.delegate = self;
	[request start];
}


- (BOOL)canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}


- (void)restoreCompletedTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)purchaseProduct:(NSString*)productIdentifier quantity:(int)quantity
{
    //	SKMutablePayment *payment = [SKMutablePayment paymentWithProductIdentifier:productIdentifier];
    SKMutablePayment *payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = productIdentifier;
    
    payment.quantity = quantity;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    //productPurchaseResult("productPurchaseCancelled", [productIdentifier UTF8String]);
}


- (void)validateReceipt:(NSString*)transactionReceipt isTestReceipt:(BOOL)isTest
{
	// Create our request and send it off.  It will be released in its delegate callback
	StoreKitReceiptRequest *request = [[StoreKitReceiptRequest alloc] initWithDelegate:self isTest:isTest];
	[request validateReceipt:transactionReceipt];
}


- (void)validateAutoRenewableReceipt:(NSString*)transactionReceipt withSecret:(NSString*)sharedSecret isTestReceipt:(BOOL)isTest
{
	// Create our request and send it off.  It will be released in its delegate callback
	StoreKitReceiptRequest *request = [[StoreKitReceiptRequest alloc] initWithDelegate:self secret:sharedSecret isTest:isTest];
	[request validateReceipt:transactionReceipt];
}


- (NSString*)getAllSavedTransactions
{
	NSMutableArray *transactions = [SKPluginTransaction savedTransactions];
	if( !transactions.count )
		return @"";
	
	NSMutableString *transactionString = [NSMutableString string];
	for( SKPluginTransaction *trans in transactions )
	{
		// extract all the relevant data from the saved transactions
		[transactionString appendFormat:@"%@|||%@|||%i||||", trans.productIdentifier, trans.base64EncodedReceipt, trans.quantity];
	}
	
	// Remove the last 4 chars ONLY if we have enough characters!
	if( transactionString.length >= 4 )
		[transactionString deleteCharactersInRange:NSMakeRange( transactionString.length - 4, 4 )];
	
	return transactionString;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SKProductsRequestDelegate
static void(*productsReceivedDelegated)(const char *productString);

-(void)setProductsReceivedDelegate:(void(*)(const char*))nameOfVoid{
    productsReceivedDelegated = nameOfVoid;
}

-(void)setDelegateiOS:(NSObject<StoreKitBindingDelegate>*)_delegate{
    delegate = _delegate;
}

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	NSLog(@"%@", [response description]);
	
	NSMutableString *productString = [NSMutableString string];
	for( SKProduct *product in response.products )
	{
		[productString appendFormat:@"%@|||%@|||%@|||%@|||%@||||", product.productIdentifier, product.localizedTitle, product.localizedDescription, product.price, [product.priceLocale objectForKey:NSLocaleCurrencySymbol]];
        NSLog( @"Product : [%@,%@,%@,%@]", product.productIdentifier, product.localizedTitle, product.localizedDescription, product.price);
	}
	
	// Remove the last 4 chars
	if( productString.length >= 4 )
		[productString deleteCharactersInRange:NSMakeRange( productString.length - 4, 4 )];
	
	for( NSString *invalidId in response.invalidProductIdentifiers )
		NSLog( @"StoreKit: invalid productIdentifier: %@", invalidId );
	
	[request autorelease];
	
    [delegate storeKit:nil getProducts:productString];
    // Send the info back to Unity
//    productsReceivedDelegated([productString UTF8String]);
}


- (void)request:(SKRequest*)request didFailWithError:(NSError*)error
{
  //  productsReceivedDelegated("");
    [delegate storeKit:nil getProducts:@""];
    //////UnitySendMessage( "StoreKitManager", "productsRequestDidFail", [[error localizedDescription] UTF8String] );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
	for( SKPaymentTransaction *transaction in transactions )
	{
		switch( transaction.transactionState )
		{
			case SKPaymentTransactionStatePurchasing:
			{
				NSLog( @"StoreKit: in the process of purchasing" );
				return;
				break;
			}
			case SKPaymentTransactionStateFailed:
			{
				if( transaction.error.code == SKErrorPaymentCancelled )
				{
//					UnitySendMessage( "StoreKitManager", "productPurchaseCancelled", [[transaction.error localizedDescription] UTF8String] );
                    //productPurchaseResult("productPurchaseCancelled", [[transaction.error localizedDescription] UTF8String]);
                    [delegate storeKit:nil productCanceled:[transaction.error localizedDescription]];
                    
					NSLog( @"StoreKit: cancelled transaction: %@", [transaction.error localizedDescription] );
				}
				else
				{
//					UnitySendMessage( "StoreKitManager", "productPurchaseFailed", [[transaction.error localizedDescription] UTF8String] );
                    //productPurchaseResult("productPurchaseFailed", [[transaction.error localizedDescription] UTF8String]);
                    [delegate storeKit:nil productCanceled:[transaction.error localizedDescription]];
					NSLog( @"StoreKit: error: %@", [transaction.error localizedDescription] );
				}
				// complete the transaction
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
			}
			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
			{
				[self completeAndRecordTransaction:transaction];
				break;
			}
		} // end switch
	} // end for
}


- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
	NSLog( @"StoreKit: ---------Doubt this will ever get called.  API is incorrect in docs.----------" );
    
    if ([delegate respondsToSelector:@selector(storeKit:failWithError:)]) [delegate storeKit:nil failWithError:nil];
}


// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
//	UnitySendMessage( "StoreKitManager", "restoreCompletedTransactionsFailed", [[error localizedDescription] UTF8String] );
	NSLog( @"restoreCompletedTransactionsFailedWithError: %@", [error localizedDescription] );
    
    if ([delegate respondsToSelector:@selector(storeKit:failWithError:)]) [delegate storeKit:nil failWithError:error];
}


// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue
{
//	UnitySendMessage( "StoreKitManager", "restoreCompletedTransactionsFinished", "" );
	NSLog( @"paymentQueueRestoreCompletedTransactionsFinished" );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark StoreKitReceiptRequestDelegate

- (void)storeKitReceiptRequest:(StoreKitReceiptRequest*)request didFailWithError:(NSError*)error
{
	[request release];
	
//	UnitySendMessage( "StoreKitManager", "validateReceiptFailed", [[error localizedDescription] UTF8String] );
}


- (void)storeKitReceiptRequest:(StoreKitReceiptRequest*)request validatedWithResponse:(NSString*)response
{
//	UnitySendMessage( "StoreKitManager", "validateReceiptRawResponse", [response UTF8String] );
}


- (void)storeKitReceiptRequest:(StoreKitReceiptRequest*)request validatedWithStatusCode:(int)statusCode
{
	[request release];

//	UnitySendMessage( "StoreKitManager", "validateReceiptFinished", [[NSString stringWithFormat:@"%i", statusCode] UTF8String] );
}

@end

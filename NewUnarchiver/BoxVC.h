//
//  BoxVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 22.10.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileVC.h"
#import "Reachability.h"

@interface BoxVC : FileVC <NSXMLParserDelegate>
{  
    long long  _spaceAmount, _spaceUsed;
    
    Reachability * _internetConnection;
}

+ (void) logOut;

@end

//
//  GoogleDriveVC.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 21.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileVC.h"

#import "Reachability.h"

@interface GoogleDriveVC : FileVC
{   
    bool _isAuthorized;
    long long  _spaceAmount, _spaceUsed;
    
    Reachability * _internetConnection;
}

+ (void) logOut;

@end

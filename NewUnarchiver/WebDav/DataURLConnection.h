//
//  DataURLConnection.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 02.11.12.
//  Copyright (c) 2012 Zhenya Koval. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CONNECTION_TYPE
{
    CONNECTION_TYPE_LOADING_FILE_LIST = 0,
    CONNECTION_TYPE_MOVING,
    CONNECTION_TYPE_COPYING,
    CONNECTION_TYPE_REMOVING,
    CONNECTION_TYPE_CREATING_FOLDER,
    CONNECTION_TYPE_UPLOADING,
    CONNECTION_TYPE_DOWNLOADING,
    
}CONNECTION_TYPE;

@interface DataURLConnection : NSURLConnection

@property (nonatomic, retain) NSMutableData * data;
@property (nonatomic, assign) CONNECTION_TYPE type;
@property (nonatomic, assign) int successCode;
@property (nonatomic, retain) id userInfo;

@property (nonatomic, assign) SEL failSelector;
@property (nonatomic, assign) SEL successSelector;

@end

/** <title>GSGormLoader</title>

   <abstract>Gorm model loader</abstract>

   Copyright (C) 1997, 1999 Free Software Foundation, Inc.

   Author:  Gregory John Casamento <greg_casamento@yahoo.com>
   Date: 2005
   
   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library;
   If not, write to the Free Software Foundation,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "GNUstepGUI/GSModelLoaderFactory.h"
#include "GNUstepGUI/GSNibCompatibility.h"

@interface GSNibLoader : GSModelLoader
@end

@implementation GSNibLoader
+ (void) initialize
{
  // should do something...
}

+ (NSString *)type
{
  return @"nib";
}

+ (float) priority
{
  return 3.0;
}

- (BOOL) loadModelFile: (NSString *)fileName
     externalNameTable: (NSDictionary *)context
              withZone: (NSZone *)zone;
{
  BOOL		loaded = NO;
  NSUnarchiver	*unarchiver = nil;

  NSDebugLog(@"Loading Nib `%@'...\n", fileName);
  NS_DURING
    {
      NSFileManager	*mgr = [NSFileManager defaultManager];
      BOOL              isDir = NO;

      if ([mgr fileExistsAtPath: fileName isDirectory: &isDir])
	{
	  NSData	*data = nil;
	  
	  // if the data is in a directory, then load from objects.gorm in the directory
	  if (isDir == NO)
	    {
	      data = [NSData dataWithContentsOfFile: fileName];
	      NSDebugLog(@"Loaded data from file...");
	    }
	  else
	    {
	      NSString *newFileName = [fileName stringByAppendingPathComponent: @"keyedobjects.nib"];
	      data = [NSData dataWithContentsOfFile: newFileName];
	      NSDebugLog(@"Loaded data from %@...",newFileName);
	    }

	  if (data != nil)
	    {
	      unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
	      if (unarchiver != nil)
		{
		  id obj;
		  
		  NSDebugLog(@"Invoking unarchiver");
		  [unarchiver setObjectZone: zone];
		  obj = [unarchiver decodeObjectForKey: @"IB.objectdata"];
		  if (obj != nil)
		    {
		      if ([obj isKindOfClass: [NSIBObjectData class]])
			{
			  NSDebugLog(@"Calling awakeWithContext");
			  [obj awakeWithContext: context];
			  loaded = YES;
			}
		      else
			{
			  NSLog(@"Nib '%@' without container object!", fileName);
			}
		    }
		  RELEASE(unarchiver);
		}
	    }
	}
    }
  NS_HANDLER
    {
      NSLog(@"Exception occured while loading model: %@",[localException reason]);
      TEST_RELEASE(unarchiver);
    }
  NS_ENDHANDLER

  if (loaded == NO)
    {
      NSLog(@"Failed to load Nib\n");
    }
  return loaded;
}
@end

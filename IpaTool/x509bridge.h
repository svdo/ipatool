//
//  x509bridge.h
//  ipatool
//
//  Created by Stefan on 21/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

#ifndef __ipatool__x509bridge__
#define __ipatool__x509bridge__

#include <stdio.h>
#include <Foundation/Foundation.h>

NSString * getX509SubjectCN(NSData *certificateData);

#endif /* defined(__ipatool__x509bridge__) */

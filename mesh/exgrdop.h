
/************************************************************************\ 
 *									*
 * exgrdop.h - command line options for exgrd                           *
 *									*
 * Copyright (c) 1995 by Georg Umgiesser				*
 *									*
 * see exgrdop.c for copying information				*
 *									*
 * Revision History:							*
 * 17-Aug-95: routines copied from meshop.c                             *
 *									*
\************************************************************************/


#ifndef __GUH_EXGRDOP_
#define __GUH_EXGRDOP_


/**************************************************************/
/**************************************************************/
/********************* global variables ***********************/
/**************************************************************/
/**************************************************************/

extern int OpArgc;

extern int OpInfo;
extern int OpExtractNodes;
extern int OpDeleteNodes;
extern int OpExtractElems;
extern int OpDeleteElems;
extern int OpExtractLines;
extern int OpDeleteLines;
extern int OpExtractUnusedNodes;
extern int OpDeleteUnusedNodes;
extern int OpMinType;
extern int OpMaxType;
extern int OpMinVertex;
extern int OpMaxVertex;
extern int OpMinRange;
extern int OpMaxRange;
extern int OpUnifyNodes;
extern int OpCompressNumbers;
extern int OpMakeAntiClockwise;
extern int OpDeleteStrangeElements;
extern float OpMinDepth;
extern float OpMaxDepth;
extern float OpTollerance;


void SetOptions(int argc, char *argv[]);
void TestVersion( void );


#endif


//
//  YBioHazardView.h
//  YBioHazard
//
//  Created by Yann Esposito on 20/06/06.
//  Copyright (c) 2006, Yann Esposito. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <QuartzComposer/QCView.h>

typedef enum {white=0, black=1, red=2} enumChoixCouleur;
typedef enum {biohazard=0, nuclear=1} enumChoixSymbole;

@interface YBioHazardView : ScreenSaverView 
{
	QCView *qcView;
	NSWindow *configurationSheet;
	NSArray *colors;
	NSImage *currentFond, *currentSymbole, *currentDessus;
	int choixCouleurLocal;
	int heureCourante;
	BOOL testMode;
}

-(void) updateQCViewColor;
-(void) updateQCViewSymbol;
-(BOOL) nouvelleHeure ;
-(IBAction) quit:(id)sender;

@end

//
//  YBioHazardView.m
//  YBioHazard
//
//  Created by Yann Esposito on 20/06/06.
//  Copyright (c) 2006, Yann Esposito. All rights reserved.
//

#import "YClockView.h"


@implementation YBioHazardView

static NSString * const YClockModuleName = @"com.YannEsposito.YClock";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		
        [self setAnimationTimeInterval:.3];
		frame.origin.x = 0;
		frame.origin.y = 0;
		qcView = [[QCView alloc] initWithFrame:frame];
		// Recherche de Biohazard.qtz
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"YClock" ofType:@"qtz"];
		if (![qcView loadCompositionFromFile:path]) {
			NSLog(@"Failed to open composition at path '%s'", path);
		}
		[self addSubview:qcView];
		[qcView setMaxRenderingFrameRate:3];
		heureCourante = [[NSCalendarDate calendarDate] hourOfDay];
		colors = [[NSArray alloc] initWithObjects:@"White", @"Black", @"Red", nil];		
		
		// récupération des préférences
		ScreenSaverDefaults *defaults;
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:YClockModuleName];
		
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			@"0", @"choixCouleur", 
			@"0", @"testMode",
			nil]];
		
		[self updateQCViewColor];
		[self updateQCViewSymbol];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
	[qcView startRendering];
}

- (void)stopAnimation
{
    [super stopAnimation];
	[qcView stopRendering];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:YClockModuleName];
	
	// Vérification si l'utilisateur a changé de couleur
	int tmp;
	tmp = [defaults integerForKey:@"choixCouleur"];
	if (tmp != choixCouleurLocal) 
	{
		choixCouleurLocal = tmp;
		[self updateQCViewColor];
	}
	
	// Vérification si l'utilisateur passe en mode de test
	testMode = [defaults boolForKey:@"testMode"];
	if (!testMode)
	{
		// Vérificiation si l'heure a changé
		if ([self nouvelleHeure])
		{
			[self updateQCViewSymbol];
		}
	}
	else {
		heureCourante = ([[NSCalendarDate calendarDate] minuteOfHour]*60 + [[NSCalendarDate calendarDate] secondOfMinute])/4 % 24;
		[self updateQCViewSymbol];
	}
    return;
}

- (BOOL) nouvelleHeure
{
	int heureReele = [[NSCalendarDate calendarDate] hourOfDay];
	if (heureCourante != heureReele)
	{
		heureCourante = heureReele;
		return YES;
	}
	return NO;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (IBAction)quit:(id)sender
{
	
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:YClockModuleName];
	
	// update the defaults
	[defaults setInteger:choixCouleurLocal forKey:@"choixCouleur"];
	[defaults setBool:testMode forKey:@"testMode"];
	[defaults synchronize];
	[self updateQCViewColor];
	
	[[NSApplication sharedApplication] endSheet:configurationSheet];
}

- (void) updateQCViewColor
{	
	NSEnumerator *i = [colors objectEnumerator];
	NSString *inputKey;	
	while (inputKey=[i nextObject]) {
		[qcView setValue:[NSNumber numberWithBool:FALSE] forInputKey:inputKey];
	}
	[qcView setValue: [NSNumber numberWithBool:TRUE] forInputKey:[colors objectAtIndex:(int)choixCouleurLocal]];	
	// GESTION DES FICHIER EN FONCTION  DE LA COULEUR COURANTE
	// récupération du chemin des fichiers ressources
	NSString *subpath;	
	subpath = [NSString stringWithFormat:@"couches%@", [colors objectAtIndex:(int)choixCouleurLocal] ];
		
	NSBundle *bundle;
	bundle = [NSBundle bundleForClass:[self class]]; 
	
	if (!bundle)
	{
		NSLog(@"impossible de retrouver le bundle pour la classe");
	}
	
	NSString *path ;
	path = [bundle pathForResource:@"arriere" ofType:@"png" inDirectory:subpath];	
	[currentFond release];
	currentFond = [NSImage alloc];
	if (path)
	{
		[currentFond initWithContentsOfFile:path];
		// ---
		path = [bundle pathForResource:@"dessus" ofType:@"png" inDirectory:subpath];
		[currentDessus release];
		currentDessus = [NSImage alloc];
		if (path)
		{
			[currentDessus initWithContentsOfFile:path];
			// ---
			int tmpNumero;
			tmpNumero = (heureCourante % 12);
			if (tmpNumero == 0)
			{
				tmpNumero=12;
			}
			NSString *tmpNomFic = [NSString stringWithFormat:@"motif%d", tmpNumero];
	
			path = [bundle pathForResource:tmpNomFic
									ofType:@"png" 
							   inDirectory:subpath];
			[currentSymbole release];
			currentSymbole = [NSImage alloc];
			if (path)
			{
				[currentSymbole initWithContentsOfFile:path];
				
				// les trois images sont chargées, reste à mettre à jour la composition quartz
				[qcView setValue:currentFond forInputKey:@"Fond"];	
				[qcView setValue:currentSymbole forInputKey:@"Symbole"];	
				[qcView setValue:currentDessus forInputKey:@"Dessus"];	
			} // -- if (path) pour le motif
		} // -- if (path) pour le dessus
	} // -- if (path) pour le derriere
}


- (void) updateQCViewSymbol
{
	NSString *subpath;	
	subpath = [NSString stringWithFormat:@"couches%@", [colors objectAtIndex:(int)choixCouleurLocal] ];
	
	
	NSBundle *bundle;
	bundle = [NSBundle bundleForClass:[self class]]; 
	
	if (!bundle)
	{
		NSLog(@"impossible de retrouver le bundle pour la classe");
	}
	
	int numTmp = heureCourante%12;
	if (numTmp == 0)
		numTmp = 12;
	NSString *tmpNomFic = [NSString stringWithFormat:@"motif%d", numTmp];
	
	NSString *path;
	path = [bundle pathForResource:tmpNomFic
							ofType:@"png" 
					   inDirectory:subpath];
	[currentSymbole release];
	currentSymbole = [NSImage alloc];
	if (path)
	{
		[currentSymbole initWithContentsOfFile:path];
		[qcView setValue:currentSymbole forInputKey:@"Symbole"];	
	} 
	return;
}



- (NSWindow*)configureSheet
{
	if (!configurationSheet)
	{	
		BOOL nibCharge = [NSBundle loadNibNamed:@"ConfigurationSheet" owner:self];
		if (!nibCharge) 
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	return configurationSheet;
}

@end

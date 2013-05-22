/* Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php */

#import "NSString+KeyCodeTranslator.h"
#import <CoreServices/CoreServices.h>
#import <Carbon/Carbon.h>


static const struct { char const* const name; unichar const glyph; } mapOfNamesForUnicodeGlyphs[] =
{
	// Constants defined in NSEvent.h that are expected to relate to unicode characters, but don't seen to translate properly
	{ "Up",			NSUpArrowFunctionKey },
	{ "Down",		NSDownArrowFunctionKey },
	{ "Left",		NSLeftArrowFunctionKey },
	{ "Right",		NSRightArrowFunctionKey },
	{ "Home",		NSHomeFunctionKey },
	{ "End",		NSEndFunctionKey },
	{ "Page Up",	NSPageUpFunctionKey },
	{ "Page Down",	NSPageDownFunctionKey },

	//	These are the actual values that these keys translate to
	{ "Up",			0x1E },
	{ "Down",		0x1F },
	{ "Left",		0x1C },
	{ "Right",		0x1D },
	{ "Home",		0x1 },
	{ "End",			0x4 },
	{ "Page Up",	0xB },
	{ "Page Down",	0xC },
	{ "Return",		0x3 },
	{ "Tab",			0x9 },
	{ "Backtab",	0x19 },
	{ "Enter",		0xd },
	{ "Backspace",	0x8 },
	{ "Delete",		0x7F },
	{ "Escape",		0x1b },
	{ "Space",		0x20 }
};

// Need to update this value if you modify mapOfNamesForUnicodeGlyphs
#define NumberOfUnicodeGlyphReplacements 24


@implementation NSString (KeyCodeTranslator)


+ (NSString *)stringForKeyCode:(UInt16)keyCode withModifierFlags:(UInt16)modifierFlags;
{
	return [self stringForKeyCode:keyCode withModifierFlags:modifierFlags usingNames:TRUE];
}


+ (NSString *)stringForKeyCode:(UInt16)keyCode withModifierFlags:(UInt16)modifierFlags usingNames:(BOOL)usingNames
{
	// Create an index set of the key codes associeted with the number pad
	static NSIndexSet *keyCodeTranslatorNumPadKeyCodes = nil;
	static dispatch_once_t createKeyCodeTranslatorNumPadKeyCodes;
	dispatch_once(&createKeyCodeTranslatorNumPadKeyCodes, ^{
		NSMutableIndexSet *padKeyCodes = [[NSMutableIndexSet alloc] init];
		[padKeyCodes addIndex:65];
		[padKeyCodes addIndex:67];
		[padKeyCodes addIndex:69];
		[padKeyCodes addIndex:71];
		[padKeyCodes addIndex:75];
		[padKeyCodes addIndex:76];
		[padKeyCodes addIndex:78];
		[padKeyCodes addIndexesInRange:NSMakeRange(81, 9)];
		[padKeyCodes addIndexesInRange:NSMakeRange(91, 2)];

		keyCodeTranslatorNumPadKeyCodes = [padKeyCodes copy];
	});
	
	
	TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
	CFDataRef uchr = (CFDataRef)TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
	const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout*)CFDataGetBytePtr(uchr);
	
	if(keyboardLayout) {
		UInt32 deadKeyState = 0;
		UniCharCount maxStringLength = 255;
		UniCharCount actualStringLength = 0;
		UniChar unicodeString[maxStringLength];
		
		OSStatus status = UCKeyTranslate(keyboardLayout,
										 keyCode, kUCKeyActionDown, (UInt32)modifierFlags,
										 LMGetKbdType(), 0,
										 &deadKeyState,
										 maxStringLength,
										 &actualStringLength, unicodeString);
		
		if(status != noErr)
			NSLog(@"There was an %d error translating from the '%d' key code.", status, keyCode);
		else if(actualStringLength > 0) {			
			// Replace certain characters with user friendly names, e.g. Space, Enter, Tab etc.
			if(usingNames) {
				NSUInteger i = 0;
				while(i <= NumberOfUnicodeGlyphReplacements) {
					if(mapOfNamesForUnicodeGlyphs[i].glyph == unicodeString[0])
						return NSLocalizedString(([NSString stringWithFormat:@"%s", mapOfNamesForUnicodeGlyphs[i].name, nil]), @"Friendly Key Name");
				
					i++;
				}
			}
			
			// NSLog(@"Unicode character as hexadecimal: %X", unicodeString[0]);
			NSString *result = [NSString stringWithCharacters:unicodeString length:actualStringLength];
			
			// Check to see if the key code represents a pad key
			if(usingNames && [keyCodeTranslatorNumPadKeyCodes containsIndex:keyCode])
				result = [NSString stringWithFormat:NSLocalizedString(@"Pad %@", @"Pad Key Format"), result];
			
			return result;
		} else
			NSLog(@"Couldn't find a translation for the '%d' key code", keyCode);			
	} else
		NSLog(@"Couldn't find a suitable keyboard layout from which to translate");
	
	return nil;
}


@end
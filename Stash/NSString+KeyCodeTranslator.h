/* Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php */


@interface NSString (KeyCodeTranslator)

+ (NSString *)stringForKeyCode:(UInt16)keyCode withModifierFlags:(UInt16)modifierFlags;
+ (NSString *)stringForKeyCode:(UInt16)keyCode withModifierFlags:(UInt16)modifierFlags usingNames:(BOOL)usingNames;

@end
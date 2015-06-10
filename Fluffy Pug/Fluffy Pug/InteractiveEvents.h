//
//  InteractiveEvents.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#ifndef __Fluffy_Pug__InteractiveEvents__
#define __Fluffy_Pug__InteractiveEvents__

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

inline void moveMouse(int x, int y);
inline void tapMouseLeft(int x, int y);
inline void tapMouseRight(int x, int y);
inline void pressMouseLeft(int x, int y);
inline void releaseMouseLeft(int x, int y);
inline void pressMouseRight(int x, int y);
inline void releaseMouseRight(int x, int y);
inline void tapSpell1();
inline void tapSpell2();
inline void tapSpell3();
inline void tapSpell4();
inline void tapActive1();
inline void tapActive2();
inline void tapActive3();
inline void tapActive5();
inline void tapActive6();
inline void tapActive7();
inline void tapWard();
inline void pressSpell1();
inline void releaseSpell1();
inline void pressSpell2();
inline void releaseSpell2();
inline void pressSpell3();
inline void releaseSpell3();
inline void pressSpell4();
inline void releaseSpell4();
inline void pressActive1();
inline void releaseActive1();
inline void pressActive2();
inline void releaseActive2();
inline void pressActive3();
inline void releaseActive3();
inline void pressWard();
inline void releaseWard();
inline void pressActive5();
inline void releaseActive5();
inline void pressActive6();
inline void releaseActive6();
inline void pressActive7();
inline void releaseActive7();
inline void pressD();
inline void releaseD();
inline void pressF();
inline void releaseF();
inline void releaseQ();
inline void releaseW();
inline void releaseE();
inline void releaseR();






extern inline void moveMouse(int x, int y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, CGPointMake(x, y), kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}
extern inline void tapMouseLeft(int x, int y) {
    moveMouse(x, y);
    pressMouseLeft(x, y);
    releaseMouseLeft(x, y);
}
extern inline void tapMouseRight(int x, int y) {
    moveMouse(x, y);
    pressMouseRight(x, y);
    releaseMouseRight(x, y);
}
extern inline void pressMouseLeft(int x, int y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(x, y), kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}
extern inline void releaseMouseLeft(int x, int y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, CGPointMake(x, y), kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}
extern inline void pressMouseRight(int x, int y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(x, y), kCGMouseButtonRight);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}
extern inline void releaseMouseRight(int x, int y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, CGPointMake(x, y), kCGMouseButtonRight);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}



extern inline void tapSpell1() {
    pressSpell1();
    releaseSpell1();
}
extern inline void tapSpell2() {
    pressSpell2();
    releaseSpell2();
}
extern inline void tapSpell3() {
    pressSpell3();
    releaseSpell3();
}
extern inline void tapSpell4() {
    pressSpell4();
    releaseSpell4();
}
extern inline void tapActive1() {
    pressActive1();
    releaseActive1();
}
extern inline void tapActive2() {
    pressActive2();
    releaseActive2();
}
extern inline void tapActive3() {
    pressActive3();
    releaseActive3();
}
extern inline void tapActive5() {
    pressActive5();
    releaseActive5();
}
extern inline void tapActive6() {
    pressActive6();
    releaseActive6();
}
extern inline void tapActive7() {
    pressActive7();
    releaseActive7();
}
extern inline void tapWard() {
    pressWard();
    releaseWard();
}
extern inline void pressSpell1() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 6, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseSpell1() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 6, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressSpell2() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 7, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseSpell2() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 7, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressSpell3() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 8, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseSpell3() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 8, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressSpell4() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 9, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseSpell4() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 9, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressActive1() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 18, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive1() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 18, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressActive2() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 19, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive2() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 19, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressActive3() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 20, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive3() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 20, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressWard() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 21, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseWard() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 21, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}




extern inline void pressActive5() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 22, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive5() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 22, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressActive6() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 23, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive6() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 23, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressActive7() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 24, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseActive7() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 24, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

extern inline void pressD() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 2, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseD() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 2, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void pressF() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 3, YES);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseF() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 3, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}



extern inline void releaseQ() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 12, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseW() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 13, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseE() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 14, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}
extern inline void releaseR() {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 15, NO);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

#endif
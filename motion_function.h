
#ifndef MOTION_FUNCTION_H
#define MOTION_FUNCTION_H

#include <Arduino.h>
#include <ld2410.h>
#include "time_functions.h"
#include "wifi_functions.h"
#define LD24_INPUT 35
extern ld2410 radar;

extern bool motion_detected;
extern int offset;
extern int  radarState;



extern int lastSeen[20]; 
extern int i ;
extern const int size ;
extern int sum ;
extern int j;





// Detect motion and act according to result
void detectMotion();

#endif
#ifndef MOTION_FUNCTION_H
#define MOTION_FUNCTION_H

#include <Arduino.h>
#include "time_functions.h"
#include "wifi_functions.h"

#define PIRInput 34
extern int pirState;
extern int val;
extern bool motion_detected;
extern int offset;

//detect motion and act according to result
void detectMotion();

#endif
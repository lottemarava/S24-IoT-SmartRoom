
#include "FS.h"
#include "SD.h"
#include "SPI.h"

 

#ifndef SD_FUNCTIONS_H
#define SD_FUNCTIONS_H
void writeFile(fs::FS &fs, const char *path, const char *message);
void SD_setup();
void SD_appendFile(fs::FS &fs, const char *path, const char *message);
#endif
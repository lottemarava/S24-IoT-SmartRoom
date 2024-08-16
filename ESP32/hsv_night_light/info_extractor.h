#ifndef INFO_EXTRACTOR_H
#define INFO_EXTRACTOR_H

#include <Arduino.h>

//dividing a merged string (of style "str1+str2+str3+...+strn") into its substrings and returning a particular substring
String getValue(String data, char separator, int index);

#endif
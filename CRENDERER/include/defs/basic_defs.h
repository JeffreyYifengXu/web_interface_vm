#ifndef _BASIC_DEFS_H
#define _BASIC_DEFS_H

#include<stddef.h>
#include<limits.h>

// Boolean
#define FALSE 0
#define TRUE !FALSE

#define ZERO 0

#define NULL_CHAR (char)0
#define NUM_START (char)'0'

// Useful data types
typedef unsigned char byte;
typedef unsigned int uint;
typedef unsigned char bool;
typedef char* str;

#define BYTE_LENGTH(x) sizeof(x) * CHAR_BIT
#define TYPE_SIZE(x) (2 ^ BYTE_LENGTH(x))


#define NUM_GENERIC_TYPES 6

enum generic_types {
	BYTE = 'b',
	UINT = 'u',
	INT = 'i',
	STR = 's',
	FLOAT = 'f',
	DOUBLE = 'd'
};

enum generic_type_chars {
};

byte str_to_byte(str string, size_t len);
uint str_to_uint(str string, size_t len);
int str_to_int(str string, size_t len);
float str_to_float(str string, size_t len);
double str_to_double(str string, size_t len);

#endif
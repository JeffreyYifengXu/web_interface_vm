#ifndef _STRING_H
#define _STRING_H

#include <stddef.h>

/*
#include <defs/basic_defs.h>

#define STR(x, y) str_constructor(x, y)
#define STRNE(x) str_constructor_ne(x)
#define STR_FREE(x) str_destructor(x)
typedef struct str {
	const char* buf;
	size_t len;
} str;

str* str_constructor(const char*, size_t);
str* str_constructor_ne(const char*);
str str_factory(char*, size_t);
void str_destructor(str*);

bool str_equals(str*, str*);
str* substring(str*, size_t, size_t);
void copy_str(str*, str*);
char* null_end(char*, size_t);
*/

char* substring(char*, size_t, size_t);
char* stringify(char*, size_t);

#endif
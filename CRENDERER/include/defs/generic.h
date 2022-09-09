#ifndef _GENERIC_H
#define _GENERIC_H

#include <defs/basic_defs.h>

#define GENERIC(x, y) generic_constructor(x, y)
#define GENERIC_FREE(x) generic_destructor(x)

typedef struct generic {
	byte type;
	void* data;
	size_t len;
} generic;

generic* generic_constructor(void*, byte, size_t);
void generic_initialise(generic*, void*, size_t, byte);
void generic_destructor(generic*);

#endif
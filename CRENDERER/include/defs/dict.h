#ifndef _DICT_H
#define _DICT_H

#include <defs/generic.h>

#define DEFAULT_DICT_SIZE 8

#define MAX_KEY_LENGTH (2 ^ 8)
#define MAX_VALUE_LENGTH (2 ^ 11)
#define MAX_LIST_LENGTH (2 ^ 16)

#define GSK_DICT() gsk_dict_constructor()
#define GSK_DICT_FREE(x) gsk_dict_destructor(x)

typedef struct gsk_dict {
	char** keys;
	generic* values;

	uint size;
	uint max_size;
} gsk_dict;

gsk_dict* gsk_dict_constructor();
void gsk_dict_add(gsk_dict*, char*, void*, size_t, byte);
generic* gsk_dict_get(gsk_dict*, char*);
void gsk_dict_destructor(gsk_dict*);

#endif
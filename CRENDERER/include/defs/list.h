#ifndef LIST_H
#define LIST_H

#include <stddef.h>

typedef struct list {
	void* data;
	size_t len;
	size_t cap;
	size_t stride;
} list;

list* list_constructor(size_t, size_t);

void list_destructor(list*);

void list_add(list*, void*);

void* list_get(list*, size_t);

#endif
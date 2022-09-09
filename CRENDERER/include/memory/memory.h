#ifndef MEMORY_H
#define MEMORY_H

#include<stddef.h>

void zero_memory(void*, size_t);

void* memalloc(size_t);
void* memrealloc(void*, size_t);
void memfree(void*);
void memcopy(void*, void*, size_t);

#endif
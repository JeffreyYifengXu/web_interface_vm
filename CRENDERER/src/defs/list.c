#include "defs/list.h"
#include "memory/memory.h"

list* list_constructor(size_t cap, size_t stride) {
	list* list = memalloc(sizeof(list));
	list->data = memalloc(stride * cap);
	list->len = 0;
	list->cap = cap;
	list->stride = stride;
	return list;
}

void list_destructor(list* l) {
	memfree(l->data);
	memfree(l);
}

void list_add(list* l, void* data) {
	if (l->len >= l->cap) {
		l->cap *= 2;
		memrealloc(l->data, l->stride * l->cap);
	}
	memcopy((char*)l->data + l->stride * l->len, data, l->stride);
}

void* list_get(list* l, size_t index) {
	return (char*)l->data + index * l->stride;
}
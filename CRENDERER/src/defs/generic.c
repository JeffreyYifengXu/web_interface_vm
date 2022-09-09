#include <defs/generic.h>
#include <memory/memory.h>
#include <defs/basic_defs.h>
#include <error/error.h>

generic* generic_constructor(void* data, byte type, size_t len) {
	generic* g = memalloc(sizeof(generic));
	size_t size = generic_sizeof(type) * len;
	g->data = memalloc(size);
	memcopy(g->data, data, size);
	g->type = type;
	return g;
}

void generic_initialise(generic* g, void* data, size_t len, byte type) {
	size_t size = generic_sizeof(type) * len;
	g->data = memalloc(size);
	memcopy(g->data, data, size);
	printf("New data type: %c\n", type);
	printf("Size: %i\n", size);
	printf("New data: %s\n", g->data);
	printf("Location: %p\n", g);
	g->type = type;
	g->len = len;
}

void generic_destructor(generic* g) {
	memfree(g->data);
	memfree(g);
}


#include <defs/dict.h>
#include <memory/memory.h>
#include <string.h>
#include <defs/string.h>

gsk_dict* gsk_dict_constructor(){
	gsk_dict* d = memalloc(sizeof(gsk_dict));
	d->max_size = DEFAULT_DICT_SIZE;
	d->size = 0;
	d->keys = memalloc(sizeof(char*) * d->max_size);
	d->values = memalloc(sizeof(generic) * d->max_size);
	return d;
}

void gsk_dict_add(gsk_dict* d, char* key, void* value, size_t len, byte type) {
	printf("New key: %s\n", key);
	while (d->size >= d->max_size) {
		d->max_size *= 2;
		d->keys = memrealloc(d->keys, sizeof(char*) * d->max_size);
		d->values = memrealloc(d->values, sizeof(generic) * d->max_size);
	}
	d->keys[d->size] = memalloc(strlen(key) + sizeof(char));
	memcopy(d->keys[d->size], key, strlen(key) + sizeof(char));
	printf("Copied key: %s\n", d->keys[d->size]);
	generic_initialise(&d->values[d->size], value, len, type);
	d->size++;
}

generic* gsk_dict_get(gsk_dict* d, char* key) {
	printf("Given: %s\n", key);
	for (uint i = 0; i < d->size; i++) {
		printf("Key: %s\n", d->keys[i]);
		if (!strcmp(key, d->keys[i])) {
			printf("Data: %p\n", &d->values[i]);
			return &d->values[i];
		}
	}
	return NULL;
}

void gsk_dict_destructor(gsk_dict* d) {
	for (int i = 0; i < d->size; i++) {
		memfree(d->keys[i]);
		GENERIC_FREE(&d->values[i]);
	}
	memfree(d->keys);
	memfree(d->values);
	memfree(d);
}
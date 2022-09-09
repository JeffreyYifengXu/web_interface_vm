#include <stdio.h>
#include <stdlib.h>

#include <memory/memory.h>
#include <defs/basic_defs.h>
#include <error/error.h>

void zero_memory(void* block, size_t length) {
	byte* byte_block = (byte*)block;
	for (size_t i = 0; i < length; i++) {
		byte_block[i] = ZERO;
	}
}

void* memalloc(size_t size) {
	IF_ZERO(size){
		THROW(_EC_ZERO_ALLOC);
		exit(_EC_ZERO_ALLOC);
	}
	void* ptr = malloc(size);
	IF_NULL(ptr) {
		THROW(_EC_OUT_OF_MEM);
		exit(_EC_OUT_OF_MEM);
	}
	return ptr;
}

void* memrealloc(void* data, size_t size) {
	IF_ZERO(size) {
		THROW(_EC_ZERO_ALLOC);
		exit(_EC_ZERO_ALLOC);
	}
	void* ptr = realloc(data, size);
	IF_NULL(ptr) {
		THROW(_EC_OUT_OF_MEM);
		exit(_EC_OUT_OF_MEM);
	}
	return ptr;
}

void memfree(void* data) {
	free(data);
}

void memcopy(void* dest, void* src, size_t len) {
	memcpy(dest, src, len);
}
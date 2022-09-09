#include <stdio.h>
#include <defs/string.h>
#include <file/file.h>
#include <error/error.h>
#include <memory/memory.h>
#include <string.h>
#include <errno.h>

char* read_file(const char* filename) {
	char* content = NULL;
	printf(filename);
	FILE* f = fopen(filename, "rb");
	IF_NULL(f) THROW(_EC_OPEN_FILE);
	else {
		fseek(f, 0, SEEK_END);
		long len = ftell(f);
		fseek(f, 0, SEEK_SET);
		content = memalloc((size_t)len + sizeof(char));
		fread(content, sizeof(char), len, f);
		printf("%ld\n", len);
		fclose(f);
		content[len] = NULL_CHAR;
	}

	return content;
}
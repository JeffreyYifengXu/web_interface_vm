#include <defs/string.h>

#include <string.h>
#include <memory/memory.h>
#include <error/error.h>

/*
str* str_constructor(const char* src, size_t len) {
	str* s = memalloc(sizeof(str));
	s->buf = memalloc(len);
	memcpy(s->buf, src, len);
	s->len = len;
	return s;
}

str* str_constructor_ne(const char* src) {
	str* s = memalloc(sizeof(str));
	s->buf = memalloc(strlen(src));
	memcpy(s->buf, src, strlen(src));
	s->len = strlen(src);
	return s;
}

void str_destructor(str* s) {
	memfree(s->buf);
	memfree(s);
}

void copy_str(str* dest, str* src) {
	dest->buf = memrealloc(dest->buf, src->len);
	memcpy(dest->buf, src->buf, src->len);
	dest->len = src->len;
}

bool str_equals(str* s1, str* s2) {
	if (s1->len != s2->len) return FALSE;
	for (size_t i = 0; i < s1->len; i++) {
		if (s1->buf[i] != s2->buf[i]) return FALSE;
	}
	return TRUE;
}

str* substring(str* src, size_t start, size_t end) {
	size_t len = end - start;
	if (len <= 0) return NULL;
	if (end > src->len) return NULL;
	if (start < 0) return NULL;
	return STR(&src->buf[start], len);
}

size_t find(str* s, char f, size_t offset) {
	for (size_t i = offset; i < s->len; i++) {
		if (s->buf[i] == f) return i;
	}
	return s->len;
}

char* null_end(char* src, size_t len) {
	char* str = memalloc(len + sizeof(char));
	memcpy(str, src, len);
	memfree(src);
	str[len] = '\0';
	return str;
}
*/

char* substring(char* src, size_t start, size_t end) {
	if (start >= end) return NULL;
	char* sub = memalloc(end - start);
	memcopy(sub, &src[start], end - start);
	return sub;
}

size_t find(char* src, char f, size_t offset) {
	for (size_t i = offset; i < strlen(src); i++) {
		if (src[i] == f) return i;
	}
	return strlen(src);
}

char* stringify(char* src, size_t len) {
	char* str = memalloc(len + sizeof(char));
	memcopy(str, src, len);
	str[len] = NULL_CHAR;
	return str;
}

bool is_whitespace(const char c) {
	if (c == '\t' || c == ' ' || c == '\n' || c == '\r') return TRUE;
	return FALSE;
}
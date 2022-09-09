#include <defs/basic_defs.h>
#include <defs/string.h>
#include <stdlib.h>

size_t generic_sizeof(byte type) {
	switch (type) {
	case BYTE:
		return sizeof(byte);
	case UINT:
		return sizeof(uint);
	case INT:
		return sizeof(int);
	case STR:
		return sizeof(char);
	case FLOAT:
		return sizeof(float);
	case DOUBLE:
		return sizeof(double);
	default:
		throw(900, "Invalid type given to generic");
		return ZERO;
	}
}

byte str_to_byte(str string, size_t len) {
	int result = 0;
	for (size_t i = 0; i < len; i++) {
		int next = string[i] - NUM_START;
		if (next >= 0 && next < 10) {
			result *= 10;
			result += next;
		}
		else if (string[i] == NULL_CHAR) {
			return result;
		}
		else {
			throw(800, "Invalid character for string conversion to byte");
			return 0;
		}
	}

	return (byte)result;
}

uint str_to_uint(str string, size_t len) {
	long int result = 0;
	for (size_t i = 0; i < len; i++) {
		int next = string[i] - NUM_START;
		if (next >= 0 && next < 10) {
			result *= 10;
			result += next;
		}
		else if (string[i] == NULL_CHAR) {
			return result;
		}
		else {
			throw(810, "Invalid character for string conversion to uint");
			return 0;
		}
	}

	return (uint)result;
}

int str_to_int(str string, size_t len) {
	int result = 0;
	for (size_t i = 0; i < len; i++) {
		int next = string[i] - NUM_START;
		if (next >= 0 && next < 10) {
			result *= 10;
			result += next;
		}
		else if (string[i] == NULL_CHAR) {
			return result;
		}
		else {
			throw(820, "Invalid character for string conversion to int");
			return 0;
		}
	}

	return (int)result;
}

float str_to_float(str string, size_t len) {
	double result = atof(string);
	return (float)result;
}

double str_to_double(str string, size_t len) {
	return atof(string);
}
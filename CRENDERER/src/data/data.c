#include <data/data.h>
#include <file/file.h>
#include <string.h>
#include <defs/string.h>
#include <memory/memory.h>
#include <error/error.h>
#include <stdio.h>

char* strip_data_whitespace(char* src) {
	bool escape = FALSE;
	size_t count = 0;
	char* stripped = memalloc(strlen(src) + 1);
	for (size_t i = 0; i < strlen(src); i++) {
		if (is_whitespace(src[i]) == FALSE || escape == TRUE) {
			stripped[count] = src[i];
			count++;
			if (src[i] == ESCAPE_CHAR) escape = !escape;
		}
	}
	memfree(src);
	stripped[count] = NULL_CHAR;
	return memrealloc(stripped, count + 1);
}

void append_if_possible(char* str, char n, size_t str_size, size_t index) {
	if (index >= str_size) {
		return;
	}
	else {
		str[index] = n;
	}
}

gsk_dict* parse_data_file(const char* filename) {
	gsk_dict* dictionary = gsk_dict_constructor();
	char* contents = read_file(filename);

	contents = strip_data_whitespace(contents);

	bool state = FALSE;
	bool escape = FALSE;
	bool list = FALSE;

	char* current_key = memalloc(MAX_KEY_LENGTH);
	size_t key_length = 0;
	char* current_value = memalloc(MAX_LIST_LENGTH * MAX_VALUE_LENGTH);
	size_t value_length = 0;
	size_t list_length = 0;
	

	byte current_type = 0;

	size_t content_length = strlen(contents);

	bool fail = FALSE;

	for (size_t i = 0; i < content_length; i++) {
		printf("Escape: %hu\n", escape);
		printf("%c", contents[i]);
		if (escape != FALSE) {
			if (contents[i] == ESCAPE_CHAR) {
				printf("\n\nfini\n\n");
				escape = FALSE;
				if (state) {
					printf("%s\n", current_value);
					switch (current_type) {
					case BYTE:
						memcopy(&current_value[list_length * sizeof(byte)], str_to_byte(&current_value[list_length * MAX_VALUE_LENGTH], value_length), sizeof(byte));
						break;
					case UINT:
						memcopy(&current_value[list_length * sizeof(uint)], str_to_uint(&current_value[list_length * MAX_VALUE_LENGTH], value_length), sizeof(uint));
						break;
					case INT:
						memcopy(&current_value[list_length * sizeof(int)], str_to_byte(&current_value[list_length * MAX_VALUE_LENGTH], value_length), sizeof(int));
						break;
					case STR:
						current_value[value_length] = NULL_CHAR;
						list_length = value_length + 1;
						break;
					case FLOAT:
						memcopy(&current_value[list_length * sizeof(float)], str_to_byte(&current_value[list_length * MAX_VALUE_LENGTH], value_length), sizeof(float));
						break;
					case DOUBLE:
						memcopy(&current_value[list_length * sizeof(double)], str_to_byte(&current_value[list_length * MAX_VALUE_LENGTH], value_length), sizeof(double));
						break;
					}
					list_length += 1;
				}
				else {
					current_key[key_length] = NULL_CHAR;
				}
			}
			else if (state) {
				printf("%c\n", contents[i]);
				printf("%i\n", list_length * MAX_VALUE_LENGTH);
				printf("%i\n", list_length);
				printf("%d\n", MAX_VALUE_LENGTH);
				append_if_possible(&current_value[list_length * MAX_VALUE_LENGTH], contents[i], MAX_VALUE_LENGTH, value_length);
				printf("%c\n", current_value[list_length * MAX_VALUE_LENGTH + value_length]);
				value_length++;
			}
			else{
				append_if_possible(current_key, contents[i], MAX_KEY_LENGTH, key_length);
				key_length++;
			}
		}
		else {
			switch (contents[i]) {
			case SPACE_CHAR:
			case NEWLINE_CHAR:
				break;
			case KEY_VAL_SEP:
				if (state) throw(2201, filename);
				else state = TRUE;
				if (i != content_length - 1) {
					switch (contents[i + 1]) {
						case BYTE:
						case UINT:
						case INT:
						case STR:
						case FLOAT:
						case DOUBLE:
							current_type = contents[i + 1];
							break;
						default:
							throw(2207, filename);
							fail = TRUE;
					}
				}
				break;
			case PAIR_SEP:
				printf("Test pair sep: %s\n", current_value);
				if (!state) {
					throw(2202, filename);
					fail = TRUE;
				}
				else state = FALSE;
				gsk_dict_add(dictionary, current_key, current_value, list_length, current_type);
				key_length = 0;
				value_length = 0;
				list_length = 0;
				break;
			case ESCAPE_CHAR:
				escape = TRUE;
				break;
			case LIST_START:
				if (list) {
					throw(2203, filename);
					fail = TRUE;
				}
				else list = TRUE;
				break;
			case LIST_END:
				if (!list) {
					throw(2204, filename);
					fail = TRUE;
				}
				else list = FALSE;
				break;
			case LIST_SEP:
				if (!list) {
					throw(2205, filename);
					fail = TRUE;
				}
				break;
			}
		}

		if (fail) {
			return NULL;
		}
		printf("Escape: %hu\n", escape);
	}

	return dictionary;
}
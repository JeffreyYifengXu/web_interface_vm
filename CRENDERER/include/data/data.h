#ifndef _DATA_H
#define _DATA_H

#include <defs/dict.h>

#define ESCAPE_CHAR (char)'\"'
#define KEY_VAL_SEP (char)':'
#define PAIR_SEP (char)';'
#define LIST_START (char)'['
#define LIST_END (char)']'
#define LIST_SEP (char)','
#define SPACE_CHAR (char)' '
#define NEWLINE_CHAR (char)'\n'

gsk_dict* parse_data_file(const char*);

#endif
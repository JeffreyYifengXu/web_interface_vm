#ifndef _ERROR_H
#define _ERROR_H

#include <defs/basic_defs.h>

#define IF_NULL(x) if(x == NULL)
#define IF_ZERO(x) if(x == ZERO)

#define THROW(x) throw(x, error_msgs[x])

enum error_codes {
	_EC_GLFW_INIT,
	_EC_GLAD_INIT,
	_EC_OUT_OF_MEM,
	_EC_ZERO_ALLOC,
	_EC_OPEN_FILE,
	_EC_SHADER_COMPILE,
	_EC_SHADER_LINK,
	_EC_WINDOW_INIT,
	_EC_RENDER_INIT,
	_EC_STR_BOUNDS,
	_MAX_ERROR_CODES
};

static const char* const error_msgs[] = {
	[_EC_GLFW_INIT] = "Failed to initialise GLFW.",
	[_EC_WINDOW_INIT] = "Failed to initialise window.",
	[_EC_GLAD_INIT] = "Failed to initialise GLAD.",
	[_EC_RENDER_INIT] = "Failed to initialise renderer.",
	[_EC_OUT_OF_MEM] = "Out of memory!",
	[_EC_ZERO_ALLOC] = "Attemping to allocate 0 bytes of memory.",
	[_EC_OPEN_FILE] = "Failed to open file.",
	[_EC_STR_BOUNDS] = "Out of bounds error with string."
};

/*
enum return_codes {
	_RC_WINDOW_INIT,
	_RC_RENDER_INIT,
	_RC_MEM_FAIL,
	_MAX_RETURN_CODES
};
*/

void throw(int, const char*);

#endif
#include <error/error.h>
#include <stdio.h>

void throw(int error_code, const char* msg){
	printf("ERROR - code %d\nMessage: %s", error_code, msg);
}
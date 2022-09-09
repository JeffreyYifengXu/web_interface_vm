#ifndef _GRAPHICS_H
#define _GRAPHICS_H

#include <glfw/glfw3.h>

#define WINDOW() window_constructor()

GLFWwindow* window_constructor();
void framebuffer_size_callback(GLFWwindow*, int, int);

void window_cleanup();

#endif
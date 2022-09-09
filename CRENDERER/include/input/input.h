#ifndef _INPUT_H
#define _INPUT_H

#include <glfw/glfw3.h>

#define KEY_PRESS(x, y) (glfwGetKey(x, y) == GLFW_PRESS)

void process_input(GLFWwindow* win);

#endif
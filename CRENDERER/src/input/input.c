#include <input/input.h>
#include <defs/basic_defs.h>

void process_input(GLFWwindow* win) {
	if (KEY_PRESS(win, GLFW_KEY_ESCAPE)) {
		glfwSetWindowShouldClose(win, TRUE);
	}
}
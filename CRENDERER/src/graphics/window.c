#include <glad/glad.h>
#include <graphics/window.h>
#include <error/error.h>

GLFWwindow* window_constructor() {
	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	GLFWwindow* win = glfwCreateWindow(800, 600, "Lionheart", NULL, NULL);
	IF_NULL(win) {
		THROW(_EC_GLFW_INIT);
		glfwTerminate();
		return NULL;
	}
	glfwMakeContextCurrent(win);

	IF_NULL(gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		THROW(_EC_GLAD_INIT);
		return NULL;
	}
	glViewport(0, 0, 800, 600);
	glfwSetFramebufferSizeCallback(win, framebuffer_size_callback);

	return win;
}

void framebuffer_size_callback(GLFWwindow* win, int width, int height) {
	glViewport(0, 0, width, height);
}

void window_cleanup() {
	glfwTerminate();
}
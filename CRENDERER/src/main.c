#include <graphics/window.h>
#include <input/input.h>
#include <error/error.h>
#include <graphics/render.h>
#include <data/data.h>

int main() {
	/*
	gsk_dict* test = parse_data_file("data/model/box.lhmdl");
	char* text = gsk_dict_get(test, "so")->data;
	printf("%s", text);
	*/
	GLFWwindow* win = WINDOW();
	IF_NULL(win) {
		THROW(_EC_WINDOW_INIT);
		return _EC_WINDOW_INIT;
	}
	renderer* r = RENDERER();
	IF_NULL(r) {
		THROW(_EC_RENDER_INIT);
		return _EC_RENDER_INIT;
	}
	while (!glfwWindowShouldClose(win)) {
		process_input(win);

		clear();

		render(r);

		glfwSwapBuffers(win);
		glfwPollEvents();
	}

	window_cleanup();

	return 0;
}
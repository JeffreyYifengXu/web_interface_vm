#include <graphics/render.h>
#include <glad/glad.h>
#include <defs/basic_defs.h>
#include <file/file.h>
#include <memory/memory.h>
#include <error/error.h>
#include <graphics/model.h>

void clear() {
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
}

renderer* renderer_constructor() {
	renderer* r = memalloc(sizeof(renderer));
	r->vertex_shader = shader_init("shaders/vertex_shader.glsl", GL_VERTEX_SHADER);
	r->fragment_shader = shader_init("shaders/fragment_shader.glsl", GL_FRAGMENT_SHADER);
	r->shader_program = glCreateProgram();
	glAttachShader(r->shader_program, r->vertex_shader);
	glAttachShader(r->shader_program, r->fragment_shader);
	glLinkProgram(r->shader_program);
	int success;
	char log[1024];
	glGetProgramiv(r->shader_program, GL_LINK_STATUS, &success);
	if (!success) {
		glGetShaderInfoLog(r->shader_program, 1024, NULL, log);
		throw(_EC_SHADER_LINK, log);
		return NULL;
	}
	glUseProgram(r->shader_program);
	glDeleteShader(r->vertex_shader);
	glDeleteShader(r->fragment_shader);

	return r;
}

void render(renderer* r) {
	model* m = MODEL();
	load_model(m);

	glUseProgram(r->shader_program);
	glDrawArrays(GL_LINE_STRIP, 0, 6);

	MODEL_FREE(m);
}

uint shader_init(const char* filename, long shader_type) {
	uint shader = glCreateShader(shader_type);
	char* src = read_file(filename);
	glShaderSource(shader, 1, &src, NULL);
	memfree(src);
	glCompileShader(shader);
	int success;
	char log[1024];
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
	if (!success) {
		glGetShaderInfoLog(shader, 1024, NULL, log);
		throw(_EC_SHADER_COMPILE, log);
	}
	return shader;
}
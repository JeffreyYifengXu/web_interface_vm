#ifndef _RENDER_H
#define _RENDER_H

#include <defs/basic_defs.h>
#include <glad/glad.h>

#define RENDERER() renderer_constructor();

typedef struct renderer {
	GLuint vertex_shader;
	GLuint fragment_shader;
	GLuint shader_program;
} renderer;

void clear();

renderer* renderer_constructor();

void render(renderer*);
uint shader_init();

#endif
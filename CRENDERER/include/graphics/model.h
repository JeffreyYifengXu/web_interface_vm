#ifndef _MODEL_H
#define _MODEL_H

#include <glad/glad.h>
#include <defs/basic_defs.h>
#include <graphics/mesh.h>

#define MODEL() model_constructor()
#define MODEL_FREE(x) model_destructor(x)

enum model_type {
	MODEL_DYNAMIC,
	MODEL_STATIC
};

typedef struct model {
	GLuint vertex_array;
	GLuint vertex_buffer;
	GLuint element_buffer;
	byte type;
	mesh* model_mesh;
} model;

model* model_constructor();
void load_model(model*);
void model_destructor(model*);

#endif
#ifndef _MESH_H
#define _MESH_H

#include <defs/basic_defs.h>

typedef struct vertex {
	float x;
	float y;
	float z;
	float tex_x;
	float tex_y;
} vertex;

vertex vertex_factory(float, float, float, float, float);

typedef struct mesh {
	vertex* vertices;
	uint* triangles;
} mesh;

mesh* mesh_constructor(const char*);
void mesh_destructor(mesh*);

#endif
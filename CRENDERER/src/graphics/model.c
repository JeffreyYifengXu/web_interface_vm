#include <graphics/model.h>
#include <memory/memory.h>

model* model_constructor() {
	model* m = memalloc(sizeof(model));
	return m;
}

void load_model(model* m) {
	float test[] = { -0.5f, -0.5f, 0.0f, 0.5f, -0.5f, 0.0f, 0.0f, 0.5f, 0.0f,
					 0.5f, -0.5f, 0.0f, 1.5f, -0.5f, 0.0f, 1.0f, 0.5f, 0.0f };
	glGenVertexArrays(1, &m->vertex_array);
	glBindVertexArray(m->vertex_array);
	glGenBuffers(1, &m->vertex_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, m->vertex_buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(test), test, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), NULL);
	glEnableVertexAttribArray(0);
}

void model_destructor(model* m) {
	memfree(m);
}
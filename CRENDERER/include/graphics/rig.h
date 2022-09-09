#ifndef _RIG_H
#define _RIG_H

#include "defs/basic_defs.h"
#include "defs/list.h"

typedef struct bone {
	bone* head;
	list* children;
	float x_rot;
	float y_rot;
	float z_rot;
	float length;
} bone;

bone* bone_constructor(bone*, float, float, float, float);

typedef struct rig {
	bone* head;
	float x_pos;
	float y_pos;
	float z_pos;
	float x_rot;
	float y_rot;
	float z_rot;
} rig;

rig* rig_constructor(const char*);
void rig_destructor(rig*);

#endif
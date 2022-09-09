#include "graphics/rig.h"
#include "memory/memory.h"

bone* bone_constructor(bone* head, float x_rot, float y_rot, float z_rot, float length) {
	bone* new_bone = memalloc(sizeof(bone));
	new_bone->head = head;
	list_add(head->children, &new_bone);
	new_bone->children = list_constructor(2, sizeof(bone*));
	new_bone->x_rot = x_rot;
	new_bone->y_rot = y_rot;
	new_bone->z_rot = z_rot;
	new_bone->length = length;
	return new_bone;
}

rig* rig_constructor(const char* filename) {
	rig* new_rig = memalloc(sizeof(rig));
	bone* head = bone_constructor(NULL, 0.0f, 0.0f, 0.0f, 0.2f);
	bone* neck = bone_constructor(head, 0.0f, 0.0f, 0.0f, 0.1f);
	bone* left_shoulder = bone_constructor(neck, 1.0f, 0.0f, 0.0f, 0.2f);
	bone* right_shoulder = bone_constructor(neck, -1.0f, 0.0f, 0.0f, 0.2f);
	bone* thorassic = bone_constructor(neck, 0.0f, 0.0f, 0.0f, 0.3f);
	new_rig->head = head;
	new_rig->x_pos = 0.0f;
	new_rig->y_pos = 0.0f;
	new_rig->z_pos = 0.0f;
	new_rig->x_rot = 0.0f;
	new_rig->y_rot = 0.0f;
	new_rig->z_rot = 0.0f;
	return new_rig;
}

void rig_destructor(rig* r) {
	memfree(r);
}
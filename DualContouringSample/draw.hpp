//
//  draw.hpp
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef draw_cpp
#define draw_cpp

#include <GL/glew.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>
#include <glm/glm.hpp>
#include <stdio.h>

class GLSLProgram;
class Mesh;

void DrawFrame(GLSLProgram& program, Mesh& mesh, const glm::vec3& pos, const glm::vec3& fwd, bool drawWireframe);

#endif /* draw_cpp */

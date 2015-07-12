//
//  draw.hpp
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef draw_cpp
#define draw_cpp

#include <glm/glm.hpp>

class GLSLProgram;
class Mesh;

void DrawFrame(GLSLProgram& program, Mesh& mesh, const glm::vec3& pos, const glm::vec3& fwd, bool drawWireframe);

#endif /* draw_cpp */

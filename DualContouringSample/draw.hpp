//
//  draw.hpp
//  DualContouringSample
//

#ifndef draw_cpp
#define draw_cpp

#include <glm/glm.hpp>

class GLSLProgram;
class Mesh;

void DrawFrame(GLSLProgram& program, Mesh& mesh, const glm::vec3& pos, const glm::vec3& fwd, bool drawWireframe);

#endif /* draw_cpp */

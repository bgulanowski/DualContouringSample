//
//  draw.cpp
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#include "draw.hpp"

#include "glsl_program.h"
#include "mesh.h"

void DrawFrame(GLSLProgram& program, Mesh& mesh, const glm::vec3& pos, const glm::vec3& fwd, bool drawWireframe)
{
    glClearColor(0.f, 0.f, 0.f, 0.f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    glm::mat4 projection = glm::perspective(60.f, 16.f/9.f, 0.1f, 500.f);
    glm::mat4 modelview = glm::lookAt(pos + fwd, glm::vec3(0.f), glm::vec3(0.f, 1.f, 0.f));
    
    glUseProgram(program.getId());
    program.setUniform("MVP", projection * modelview);
    program.setUniformInt("useUniformColour", 0);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    glBindVertexArray(mesh.vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, mesh.numIndices_, GL_UNSIGNED_INT, (void*)0);
    
    if (drawWireframe)
    {
        glm::mat4 wireframe = glm::translate(glm::mat4(1), 0.02f * -fwd);
        
        program.setUniform("MVP", projection * modelview * wireframe);
        program.setUniformInt("useUniformColour", 1);
        program.setUniform("colour", glm::vec4(1));
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glDrawElements(GL_TRIANGLES, mesh.numIndices_, GL_UNSIGNED_INT, (void*)0);
    }
    
    glUseProgram(0);
}

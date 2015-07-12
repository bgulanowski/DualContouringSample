//
//  app.hpp
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef app_cpp
#define app_cpp

#include <stdio.h>
#include <stdlib.h>

#include "glsl_program.h"
#include "mesh.h"
#include "octree.h"

class app {
    
public:
    app() : program(), mesh(), root(nullptr), lastFrameTime(0) {};
    
    bool run( void );
    
private:
    bool initialize( void );
    void mainLoop( void );
    void cleanup( void );
    
    bool initSDL( void );
    bool initGL( void );
    bool loadProgram( void );
    void printHelp( void );
    
    void reloadMesh( void );
    bool handleInput( void );
    
    void HandleMouseMove(const SDL_MouseMotionEvent& e);
    void HandleMouseWheel(const SDL_MouseWheelEvent& e);
    void HandleKeyPress(const SDL_KeyboardEvent& e);

    SDL_Window* window;
    GLSLProgram program;
    Mesh mesh;
    OctreeNode* root = nullptr;
    Uint32 lastFrameTime = 0;
    
    float rotateX = -60.f, rotateY = 0.f;
    float distance = 100.f;
    bool drawWireframe = false;
    bool refreshMesh = false;
    int thresholdIndex = -1;
};

#endif /* app_cpp */

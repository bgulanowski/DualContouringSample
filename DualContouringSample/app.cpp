//
//  app.cpp
//  DualContouringSample
//

#include "app.hpp"
#include "draw.hpp"

const static int MAX_THRESHOLDS = 5;
const static float THRESHOLDS[MAX_THRESHOLDS] = { -1.f, 0.1f, 1.f, 10.f, 50.f };
// octreeSize must be a power of two!
const static int octreeSize = 64;

bool app::run() {
    if(initialize()) {
        mainLoop();
        cleanup();
        return true;
    }
    else {
        return false;
    }
}

bool app::initialize() {
    
    if(!initSDL()) {
        return false;
    }
    
    if (!initGL()) {
        return false;
    }
    
    printHelp();
    
    mesh.initialise();
    reloadMesh();
    
    return true;
}

bool app::initSDL( void ) {

    if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
    {
        printf("Error: SDL_Init failed: %s\n", SDL_GetError());
        return nullptr;
    }
    
    window = SDL_CreateWindow("DualContourStarter", 100, 100, 1280, 720, SDL_WINDOW_OPENGL);
    if (!window)
    {
        printf("Error: SDL_CreateWindow failed: %s\n", SDL_GetError());
        return false;
    }
    
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    
    SDL_GLContext context = SDL_GL_CreateContext(window);
    if (!context)
    {
        printf("Error: SDL_GL_CreateContext failed: %s\n", SDL_GetError());
        return false;
    }
    
    SDL_GL_MakeCurrent(window, context);
    
    return true;
}

bool app::initGL( void ) {
    
    glewExperimental = true;
    if (glewInit() != GLEW_OK)
    {
        printf("Error: glewInit failed\n");
        return false;
    }
    
    glViewport(0, 0, 1280, 720);
    
    // getting an (suprious?) error from glew here, just ignore
    glGetError();
    
    if (!loadProgram()) {
        return false;
    }
    
    return true;
}

bool app::loadProgram( void ) {
    
    program = GLSLProgram();
    
    if (!program.initialise() ||
        !program.compileShader(ShaderType_Vertex, "shader.vert") ||
        !program.compileShader(ShaderType_Fragment, "shader.frag") ||
        !program.link())
    {
        printf("Error: failed to create GLSL program\n");
        return false;
    }
    return true;
}

void app::printHelp() {
    
    printf("----------------------------------------------------------------\n");
    printf("The controls are:\n");
    printf("	- hold left mouse and drag to rotate the view\n");
    printf("	- use the mouse wheel to zoom in/out\n");
    printf("	- press F1 to render a wireframe\n");
    printf("	- press F2 to regenerate the octree using a new error threshold (and generate a new mesh)\n");
    printf("----------------------------------------------------------------\n");
    printf("\n\n");
    
    printf("OpenGL version: %s\n", glGetString(GL_VERSION));
    printf("OpenGL shading version: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

void app::reloadMesh( void ) {
    
    thresholdIndex = (thresholdIndex + 1) % MAX_THRESHOLDS;
    printf("Generating mesh with error threshold=%.1f...\n", THRESHOLDS[thresholdIndex]);
    auto startTime = SDL_GetTicks();
    
    VertexBuffer vertices;
    IndexBuffer indices;
    
    root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, THRESHOLDS[thresholdIndex]);
    GenerateMeshFromOctree(root, vertices, indices);
    mesh.uploadData(vertices, indices);
    printf("Generated mesh (%.1fs)\n\n", (float)(SDL_GetTicks() - startTime) / 1000.f);
    
    refreshMesh = false;
}

// ----------------------------------------------------------------------------

bool app::handleInput( void ) {
    
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
            case SDL_QUIT:
                return true;
                break;
                
            case SDL_MOUSEMOTION:
                HandleMouseMove(event.motion);
                break;
                
            case SDL_MOUSEWHEEL:
                HandleMouseWheel(event.wheel);
                break;
                
            case SDL_KEYUP:
                HandleKeyPress(event.key);
                break;
        }
    }
    
    return false;
}

// ----------------------------------------------------------------------------

void app::mainLoop( void ) {
    
    while (handleInput() == false)
    {
        if (refreshMesh)
        {
            reloadMesh();
        }
        
        if ((SDL_GetTicks() - lastFrameTime) < 33)
        {
            continue;
        }
        
        lastFrameTime = SDL_GetTicks();
        
        // calculate the forward vector and then use that to find the camera position
        glm::vec3 dir(0.f, 0.f, 1.f);
        dir = glm::rotateX(dir, rotateX);
        dir = glm::rotateY(dir, rotateY);
        
        glm::vec3 position = dir * distance;
        
        DrawFrame(program, mesh, position, -dir, drawWireframe);
        
        SDL_GL_SwapWindow(window);
    }
}

void app::cleanup( void ) {
    
    DestroyOctree(root);
    mesh.destroy();
    
    SDL_GL_DeleteContext(SDL_GL_GetCurrentContext());
    SDL_Quit();
}

#pragma mark - Event Handlers

void app::HandleMouseMove(const SDL_MouseMotionEvent& e)
{
    if (e.state & SDL_BUTTON_LMASK)
    {
        rotateX += (float)e.yrel * 0.05f;
        rotateY += (float)e.xrel * 0.05f;
        
//		rotateX = glm::min(80.f, rotateX);
//		rotateX = glm::max(-80.f, rotateX);
    }
}

void app::HandleMouseWheel(const SDL_MouseWheelEvent& e)
{
    distance += -e.y * 10.f;
}

void app::HandleKeyPress(const SDL_KeyboardEvent& e)
{
    if (e.type != SDL_KEYUP)
    {
        return;
    }
    
    switch (e.keysym.sym)
    {
        case SDLK_F1:
            drawWireframe = !drawWireframe;
            break;
            
        case SDLK_F2:
            refreshMesh = true;
            break;
    }
}


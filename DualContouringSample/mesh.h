#ifndef		HAS_MESH_H_BEEN_INCLUDED
#define		HAS_MESH_H_BEEN_INCLUDED

#include <vector>

#if defined Cocoa
#include <OpenGL/gl3.h>
#else
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>
#endif
#include <glm/glm.hpp>

#include "serialization.h"

// ----------------------------------------------------------------------------

struct MeshVertex : serialize::I
{
    MeshVertex() : xyz(0), normal(0) {}
	MeshVertex(const glm::vec3& _xyz, const glm::vec3& _normal)
		: xyz(_xyz)
		, normal(_normal)
	{
	}

    ostream& write(ostream& s)
    {
        serialize::write(s, xyz.x);
        serialize::write(s, xyz.y);
        serialize::write(s, xyz.z);
        serialize::write(s, normal.x);
        serialize::write(s, normal.y);
        serialize::write(s, normal.z);
        
        return s;
    }
    istream& read(istream& s)
    {
        serialize::read(s, xyz.x);
        serialize::read(s, xyz.y);
        serialize::read(s, xyz.z);
        serialize::read(s, normal.x);
        serialize::read(s, normal.y);
        serialize::read(s, normal.z);
        
        return s;
    }

    glm::vec3		xyz, normal;
};

typedef std::vector<MeshVertex> VertexBuffer;
typedef std::vector<int> IndexBuffer;

// ----------------------------------------------------------------------------

class Mesh
{
public:

	Mesh()
		: vertexArrayObj_(0)
		, vertexBuffer_(0)
		, indexBuffer_(0)
		, numIndices_(0)
	{
	}

	void initialise();
	void uploadData(const VertexBuffer& vertices, const IndexBuffer& indices);
	void destroy();

	GLuint			vertexArrayObj_, vertexBuffer_, indexBuffer_;
	int				numIndices_;
};

// ----------------------------------------------------------------------------

#endif	//	HAS_MESH_H_BEEN_INCLUDED

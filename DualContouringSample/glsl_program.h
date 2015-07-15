#ifndef		HAS_GLSL_PROGRAM_H_BEEN_INCLUDED
#define		HAS_GLSL_PROGRAM_H_BEEN_INCLUDED

#if defined Cocoa
#include <OpenGL/gl3.h>
#else
#include <GL/glew.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>
#endif

#include <vector>
#include <glm/glm.hpp>
#include <glm/ext.hpp>

#if defined __GNUC__ || defined __APPLE__
#include <unordered_map>
#else
#include <hash_map>
#endif

enum GLSLShaderTypes
{
	ShaderType_Vertex,
	ShaderType_Fragment
};

class GLSLProgram
{
public:

	GLSLProgram();
	virtual ~GLSLProgram();

	virtual bool initialise();
	void prependLine(const std::string& line);

	bool compileShader(GLSLShaderTypes type, const std::string& filePath);
	bool link();

	GLuint getId() const;
	bool getUniform(const std::string& name, glm::mat4& uniform);
	bool getSubroutineIndex(const std::string& name, GLuint& uniform);

	bool setUniform(const std::string& name, const glm::mat4& uniform);
	bool setUniform(const std::string& name, const glm::mat3& uniform);
	bool setUniform(const std::string& name, const glm::vec4& uniform);
	bool setUniform(const std::string& name, const glm::vec3& uniform);

	// NB: overloading deliberately avoided here to prevent problems with literals
	// being converted, e.g. with an integer setUniform func setUniform("bob", 1.f)
	// will call the variant, which can be very confusing (although it does generate a warning)
	bool setUniformFloat(const std::string& name, const float uniform);
	bool setUniformInt(const std::string& name, const GLuint uniform);

private:

	void printShaderInfo(GLuint shader) const;
	void printProgramInfo(GLuint program) const;

	GLuint					program_;
	std::vector<GLuint>		shaders_;
	std::string				header_;

	// Hash the locations of the uniforms to prevent glGet calls during frames
    typedef std::unordered_map<std::string, GLint> UniformLocations;
	UniformLocations		uniformLocations_;

	const GLint getUniformLocation(const std::string& name);
};

#endif	//	HAS_GLSL_PROGRAM_H_BEEN_INCLUDED


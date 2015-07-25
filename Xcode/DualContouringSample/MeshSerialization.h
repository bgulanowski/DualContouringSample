//
//  MeshSerialization.h
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-25.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef MeshSerialization_h
#define MeshSerialization_h

#include <stdio.h>

#include "serialization.h"

#import <fstream>
#import <string>

inline static std::ostream& write(std::ostream& ostream_, glm::vec3& vertex)
{
    serialize::write(ostream_, vertex.x);
    serialize::write(ostream_, vertex.y);
    serialize::write(ostream_, vertex.z);
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, glm::vec3& vertex)
{
    serialize::read(istream_, vertex.x);
    serialize::read(istream_, vertex.y);
    serialize::read(istream_, vertex.z);
    return istream_;
}

inline static std::ostream& write(std::ostream& ostream_, MeshVertex& vertex)
{
    write(ostream_, vertex.xyz);
    write(ostream_, vertex.normal);
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, MeshVertex& vertex)
{
    read(istream_, vertex.xyz);
    read(istream_, vertex.normal);
    return istream_;
}

inline static std::ostream& write(std::ostream& ostream_, VertexBuffer& vertexBuffer_)
{
    for (VertexBuffer::iterator i=vertexBuffer_.begin(); i<vertexBuffer_.end(); ++i) {
        write(ostream_, *i);
    }
    
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, VertexBuffer& vertexBuffer_)
{
    while (!istream_.eof()) {
        MeshVertex vertex(glm::vec3(0), glm::vec3(0));
        read(istream_, vertex);
        vertexBuffer_.push_back(vertex);
    }
    
    return istream_;
}

inline static std::ostream& write(std::ostream& ostream_, IndexBuffer& indexBuffer_)
{
    return serialize::write(ostream_, indexBuffer_);
}

inline static std::istream& read(std::istream& istream_, IndexBuffer& indexBuffer_)
{
    return serialize::read(istream_, indexBuffer_);
}

template<typename T> inline static void load(std::string& fileName, std::vector<T>& vector)
{
    std::ifstream file(fileName, std::ios::in | std::ios::binary);
    if (file.good()) {
        read(file, vector);
        file.close();
    }
}

template<typename T> inline static void save(std::string& fileName, std::vector<T>& vector)
{
    std::ofstream file(fileName, std::ios::out | std::ios::binary | std::ios::trunc);
    write(file, vector);
    file.flush();
    file.close();
}

#endif /* MeshSerialization_h */

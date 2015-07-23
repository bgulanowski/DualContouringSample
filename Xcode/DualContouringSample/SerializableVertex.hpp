//
//  SerializableVertex.hpp
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-23.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef SerializableVertex_cpp
#define SerializableVertex_cpp

#include <stdio.h>
#include "mesh.h"
#include "serialization.h"

class SerializableVertex : public MeshVertex, serialize::I {
public:
    SerializableVertex() : MeshVertex(glm::vec3(0), glm::vec3(0)) {}
    SerializableVertex(const glm::vec3& _xyz, const glm::vec3& _normal) : MeshVertex(_xyz, _normal) {}
    
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

    virtual ~SerializableVertex() {}
};

#endif /* SerializableMesh_cpp */

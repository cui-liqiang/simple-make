#include "domain/Post.h"

Post::Post(std::string& name)
:name(name)
{	
}

std::string Post::getName() const
{
	return name;
}


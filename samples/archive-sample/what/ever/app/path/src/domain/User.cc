#include "domain/User.h"

User::User(std::string& name)
:name(name)
{	
}

std::string User::getName() const
{
	return name;
}


#ifndef USER_H_
#define USER_H_

#include <string>

struct User
{
	User(std::string& name);
	std::string getName() const;
private:
	std::string name;
};

#endif
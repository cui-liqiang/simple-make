#ifndef POST_H_
#define POST_H_

#include <string>

struct Post
{
	Post(std::string& name);
	std::string getName() const;
private:
	std::string name;
};

#endif
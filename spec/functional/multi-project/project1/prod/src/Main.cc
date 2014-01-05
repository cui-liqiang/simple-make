#include <iostream>
#include "domain/User.h"
#include "domain/Post.h"
#include <string>

int main()
{
	std::cout<<"in prod"<<std::endl;
	std::string name = "liqiang";
	User user(name);
	std::cout<<"user name:"<<user.getName()<<std::endl;
	Post post(name);
	std::cout<<"post name:"<<post.getName()<<std::endl;
}
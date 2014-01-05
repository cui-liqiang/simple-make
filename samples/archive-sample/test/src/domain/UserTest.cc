#include "gtest/gtest.h"
#include "domain/User.h"

struct UserTest: testing::Test
{
};

TEST_F(UserTest, should_get_the_right_name)
{
	std::string name = "liqiang";
	User user(name);
	ASSERT_EQ(std::string("liqiang"), user.getName());
}
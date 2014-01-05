#include "gtest/gtest.h"
#include "domain/Post.h"

struct PostTest: testing::Test
{
};

TEST_F(PostTest, should_get_the_right_name)
{
	std::string name = "liqiang";
	Post post(name);
	ASSERT_EQ(std::string("liqiang"), post.getName());
}
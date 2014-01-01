#--------------------configurations-----------------
APP_PATH = app
TEST_PATH = test
PROD_PATH = prod
PROJECT_NAME = sample-project
OUTPUT_PATH = build
SOURCE_FOLDER_NAME = src

#--------------------flags-----------------
DEPS_FLAG = -MMD -MP -MF"$(@:%.o=%.d)"
CC = g++ -O0 -g3 -Wall
LINK = g++

#--------------------source files-----------------
SRCS = app/src/domain/User.cc
TEST_SRCS = test/src/domain/UserTest.cc
PROD_SRCS = prod/src/Main.cc

#--------------------folders-----------------

FOLDERS = build/app/domain \
build/app/service \
build/app/util \
build/app \
build/prod \
build/test/domain \
build/test

#--------------------objs-----------------
OBJS += $(patsubst $(APP_PATH)/$(SOURCE_FOLDER_NAME)/%.cc, $(OUTPUT_PATH)/app/%.o, $(SRCS))
TEST_OBJS += $(patsubst $(TEST_PATH)/$(SOURCE_FOLDER_NAME)/%.cc, $(OUTPUT_PATH)/test/%.o, $(TEST_SRCS))
PROD_OBJS += $(patsubst $(PROD_PATH)/$(SOURCE_FOLDER_NAME)/%.cc, $(OUTPUT_PATH)/prod/%.o, $(PROD_SRCS))

#--------------------deps-----------------
DEPS += $(OBJS:.o=.d)
TEST_DEPS += $(TEST_OBJS:.o=.d)
PROD_DEPS += $(PROD_OBJS:.o=.d)
ALL_DEPS = $(DEPS) $(TEST_DEPS) $(PROD_DEPS)

#--------------------compile rules-----------------

$(TEST_OBJS): $(OUTPUT_PATH)/test/%.o: $(TEST_PATH)/$(SOURCE_FOLDER_NAME)/%.cc
	$(CC) -I/Users/twer/RubymineProjects/simple-make/sample-project/app/include -I/Users/twer/RubymineProjects/simple-make/sample-libs/includes $(DEPS_FLAG) -c -o "$@" "$<"
$(OBJS): $(OUTPUT_PATH)/app/%.o: $(APP_PATH)/$(SOURCE_FOLDER_NAME)/%.cc
	$(CC) -I/Users/twer/RubymineProjects/simple-make/sample-project/app/include $(DEPS_FLAG) -c -o "$@" "$<"
$(PROD_OBJS): $(OUTPUT_PATH)/prod/%.o: $(PROD_PATH)/$(SOURCE_FOLDER_NAME)/%.cc
	$(CC) -I/Users/twer/RubymineProjects/simple-make/sample-project/app/include $(DEPS_FLAG) -c -o "$@" "$<"

#--------------------ut-----------------
$(OUTPUT_PATH)/$(PROJECT_NAME)_ut: $(OBJS) $(TEST_OBJS)
	$(LINK) -o $(OUTPUT_PATH)/$(PROJECT_NAME)_ut -L/Users/twer/RubymineProjects/simple-make/sample-libs/libs/ ${TEST_OBJS} $(OBJS) -lgtest_main
test: init $(OUTPUT_PATH)/$(PROJECT_NAME)_ut
	$(OUTPUT_PATH)/$(PROJECT_NAME)_ut

#--------------------package-----------------
$(OUTPUT_PATH)/$(PROJECT_NAME): $(OBJS) $(PROD_OBJS)
	$(LINK) -o $(OUTPUT_PATH)/$(PROJECT_NAME)  ${PROD_OBJS} $(OBJS) 
run: init $(OUTPUT_PATH)/$(PROJECT_NAME)
	$(OUTPUT_PATH)/$(PROJECT_NAME)
package: $(OUTPUT_PATH)/$(PROJECT_NAME)

#--------------------misc-----------------
$(FOLDERS): %:
	mkdir -p "$@"
init:$(FOLDERS)
clean:
	rm -rf $(OBJS) $(TEST_OBJS) $(PROD_OBJS) $(ALL_DEPS) $(OUTPUT_PATH)/$(PROJECT_NAME) $(OUTPUT_PATH)/$(PROJECT_NAME)_ut $(FOLDERS)

.PHONY: clean init

-include $(ALL_DEPS)
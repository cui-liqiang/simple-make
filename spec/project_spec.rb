require "spec_helper"
require "simple-make/project"

describe "Project" do
  before(:each) do
    @project = Project.new
  end

  context "when generating search path" do
    before(:each) do
      @project.depend_on(
          {scope: :compile, include: "dep/for/compile", lib: "dep/for/compile/lib"},
          {scope: :test, include: "dep/for/test", lib: "dep/for/test/lib"},
          {scope: :prod, include: "dep/for/prod", lib: "dep/for/prod/lib"}
      )

      @project.header_search_path(
          {scope: :compile, path: "for/compile/headers"},
          {scope: :test, path: "for/test/headers"},
          {scope: :prod, path: "for/prod/headers"}
      )
    end

    def search_path_include *path
      /#{path.map{|p| "-I.+\/#{p.gsub("/", "\/")}"}.join(" ")}/
    end

    it "should generate correct -I flag for compile time" do
      @project.compile_time_search_path_flag.should match search_path_include("app/include", "compile/headers","dep/for/compile")
    end

    it "should generate empty string if no compile time search path present" do
      Project.new.compile_time_search_path_flag.should match search_path_include("app/include")
    end

    it "should generate correct -I flag for test" do
      @project.test_time_search_path_flag.should match search_path_include("app/include", "for/compile/headers", "dep/for/compile",
                                                                           "for/test/headers", "dep/for/test")
    end

    it "should generate empty string if no compile and test time search path present" do
      Project.new.test_time_search_path_flag.should match search_path_include("app/include")
    end

    it "should generate correct -I flag for prod" do
      @project.prod_time_search_path_flag.should match search_path_include("app/include", "for/compile/headers", "dep/for/compile",
                                                                           "for/prod/headers", "dep/for/prod")
    end

    it "should generate empty string if no compile and prod time search path present" do
      Project.new.prod_time_search_path_flag.should match search_path_include("app/include")
    end
  end

  context "when generating lib related" do
    before(:each) do
      @project.depend_on(
          {scope: :compile, include: "dep/for/compile", lib: "dep/for/compile/liblib1.a"},
          {scope: :test, include: "dep/for/test", lib: "dep/for/test/liblib2.a"},
          {scope: :prod, include: "dep/for/prod", lib: "dep/for/prod/liblib3.a"}
      )
    end

    context "for lib path" do
      def lib_path_include *lib_paths
        /#{lib_paths.map{|p| "-L.+\/#{p.gsub("/", "\/")}"}.join(" ")}/
      end

      it "should generate correct -L flag for test" do
        @project.test_time_lib_path_flag.should match lib_path_include("dep/for/compile/", "dep/for/test/")
      end

      it "should generate correct -L flag for prod" do
        @project.prod_time_lib_path_flag.should match lib_path_include("dep/for/compile/", "dep/for/prod/")
      end

      it "should handle libs without /" do
        @project.depend_on({scope: :compile, include: "dep/for/compile", lib: "liblib.a"})

        @project.prod_time_lib_path_flag.should match lib_path_include("dep/for/compile/", "dep/for/prod/")
      end
    end

    context "for lib name" do
      it "should generate correct -l flag for test" do
        @project.test_time_lib_flag.should == "-llib1 -llib2"
      end

      it "should generate correct -L flag for prod" do
        @project.prod_time_lib_flag.should == "-llib1 -llib3"
      end

      it "should throw exception if lib name is not formated as 'libxxx.a'" do
        @project.depend_on(
            {scope: :compile, include: "dep/for/compile", lib: "dep/for/compile/wrongformat"},
        )

        expect {@project.test_time_lib_flag}.to raise_error("lib name format is wrong, it should be [libxxx.a]")
      end

      it "should throw exception if lib name is not formated as 'lib.a'" do
        @project.depend_on({scope: :compile, include: "dep/for/compile", lib: "dep/for/compile/lib.a"})

        expect {@project.test_time_lib_flag}.to raise_error("lib name format is wrong, it should be [libxxx.a], and the xxx should not be empty")
      end

      it "should handle libs without /" do
        @project.depend_on({scope: :compile, include: "dep/for/compile", lib: "liblib.a"})

        @project.prod_time_lib_flag.should == "-llib1 -llib -llib3"
      end
    end
  end

end
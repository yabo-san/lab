class Tilengine < Formula
  desc "2D graphics engine with raster effects for retro/classic style games"
  homepage "https://www.tilengine.org"
  head "https://github.com/megamarc/Tilengine.git", branch: "master"

  depends_on "sdl2"
  depends_on "libpng"

  def install
    cd "src" do
      # Set up environment for macOS build
      ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"

      # Get Homebrew's SDL2 paths
      sdl2 = Formula["sdl2"]

      # Fix Makefile for ARM Macs and Homebrew SDL2
      inreplace "Makefile" do |s|
        # Replace framework SDL2 with Homebrew SDL2
        s.gsub! "-framework SDL2", "-L#{sdl2.opt_lib} -lSDL2"
        # Fix library path for ARM architecture
        s.gsub! "LIBPATH = ../lib/darwin_x86_64", "LIBPATH = ../lib/darwin_#{Hardware::CPU.arch}"
      end

      # Compile the library
      system "make"

      # Find where the library was actually built
      # It might be in src/ directly, not in ../lib/darwin_*/
      if File.exist?("Tilengine.dylib")
        # Install with standard naming convention
        lib.install "Tilengine.dylib" => "libTilengine.dylib"
        # Fix the install name so it can be found
        system "install_name_tool", "-id", "#{lib}/libTilengine.dylib", "#{lib}/libTilengine.dylib"
      elsif File.exist?("../lib/darwin_#{Hardware::CPU.arch}/Tilengine.dylib")
        lib.install "../lib/darwin_#{Hardware::CPU.arch}/Tilengine.dylib" => "libTilengine.dylib"
        system "install_name_tool", "-id", "#{lib}/libTilengine.dylib", "#{lib}/libTilengine.dylib"
      else
        # Search for it
        dylib_path = Dir["**/Tilengine.dylib"].first
        odie "Could not find Tilengine.dylib" unless dylib_path
        lib.install dylib_path => "libTilengine.dylib"
        system "install_name_tool", "-id", "#{lib}/libTilengine.dylib", "#{lib}/libTilengine.dylib"
      end

      # Install headers
      include.install "../include/Tilengine.h"

      # Install pkg-config file
      (lib/"pkgconfig").mkpath
      (lib/"pkgconfig/tilengine.pc").write <<~EOS
        prefix=#{prefix}
        exec_prefix=${prefix}
        libdir=${exec_prefix}/lib
        includedir=${prefix}/include

        Name: Tilengine
        Description: 2D graphics engine with raster effects
        Version: HEAD
        Libs: -L${libdir} -lTilengine
        Cflags: -I${includedir}
      EOS

      # Install cmake config
      (lib/"cmake/Tilengine").mkpath
      (lib/"cmake/Tilengine/tilengine-config.cmake").write <<~EOS
        set(TILENGINE_INCLUDE_DIRS "#{include}")
        set(TILENGINE_LIBRARIES "#{lib}/libTilengine.dylib")
        set(TILENGINE_FOUND TRUE)

        if(NOT TARGET Tilengine::Tilengine)
          add_library(Tilengine::Tilengine SHARED IMPORTED)
          set_target_properties(Tilengine::Tilengine PROPERTIES
            IMPORTED_LOCATION "#{lib}/libTilengine.dylib"
            INTERFACE_INCLUDE_DIRECTORIES "#{include}"
          )
        endif()
      EOS
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <Tilengine.h>
      #include <stdio.h>

      int main(void) {
        if (TLN_Init(400, 240, 1, 0, 0)) {
          printf("Tilengine initialized successfully\\n");
          TLN_Deinit();
          return 0;
        }
        return 1;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}",
           "-lTilengine", "-o", "test"
    system "./test"
  end
end

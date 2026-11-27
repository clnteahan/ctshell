{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ cargo rustc pkg-config ];
  buildInputs = with pkgs; [
    wayland libxkbcommon vulkan-loader libGL
    libx11 libxcursor libxrandr
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    wayland libxkbcommon vulkan-loader libGL
    libx11 libxcursor libxrandr
  ]);
}

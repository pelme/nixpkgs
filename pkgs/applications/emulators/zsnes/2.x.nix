{ lib
, stdenv
, fetchFromGitHub
, SDL
, libGL
, libGLU
, libpng
, nasm
, pkg-config
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zsnes2";
  version = "2.0.10";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = "zsnes";
    rev = finalAttrs.version;
    hash = "sha256-QFPl3I2nFWMmgQRGxrlt4Vh5N4SygvBLjeFiQpgRr8o=";
  };

  nativeBuildInputs = [
    nasm
    pkg-config
  ];

  buildInputs = [
    SDL
    libGL
    libGLU
    libpng
    zlib
  ];

  dontConfigure = true;

  NIX_CFLAGS_COMPILE = [
    # Until upstream fixes the issues...
    "-Wp,-D_FORTIFY_SOURCE=0"
  ];

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  postInstall = ''
    install -Dm644 linux/zsnes.desktop $out/share/applications/zsnes.desktop
    install -Dm644 icons/16x16x32.png $out/share/icons/hicolor/16x16/apps/zsnes.png
    install -Dm644 icons/32x32x32.png $out/share/icons/hicolor/32x32/apps/zsnes.png
    install -Dm644 icons/48x48x32.png $out/share/icons/hicolor/48x48/apps/zsnes.png
    install -Dm644 icons/64x64x32.png $out/share/icons/hicolor/64x64/apps/zsnes.png
  '';

  meta = {
    homepage = "https://github.com/xyproto/zsnes";
    description = "A maintained fork of zsnes";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.AndersonTorres ];
    platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86;
  };
})

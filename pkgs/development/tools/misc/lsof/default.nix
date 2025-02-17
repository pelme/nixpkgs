{ lib, stdenv, fetchFromGitHub, buildPackages, perl, which, ncurses }:

let
  dialect = with lib; last (splitString "-" stdenv.hostPlatform.system);
in

stdenv.mkDerivation rec {
  pname = "lsof";
  version = "4.96.5";

  src = fetchFromGitHub {
    owner = "lsof-org";
    repo = "lsof";
    rev = version;
    hash = "sha256-3ZEGCKc7inbqcE4LuhfKON3C8LebVOlZPEhOHVgx8Lo=";
  };

  patches = [
    ./no-build-info.patch
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isMusl ''
    substituteInPlace dialects/linux/dlsof.h --replace "defined(__UCLIBC__)" 1
  '' + lib.optionalString stdenv.isDarwin ''
    sed -i 's|lcurses|lncurses|g' Configure
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ perl which ];
  buildInputs = [ ncurses ];

  # Stop build scripts from searching global include paths
  LSOF_INCLUDE = "${lib.getDev stdenv.cc.libc}/include";
  configurePhase = "LINUX_CONF_CC=$CC_FOR_BUILD LSOF_CC=$CC LSOF_AR=\"$AR cr\" LSOF_RANLIB=$RANLIB ./Configure -n ${dialect}";

  preBuild = ''
    for filepath in $(find dialects/${dialect} -type f); do
      sed -i "s,/usr/include,$LSOF_INCLUDE,g" $filepath
    done
  '';

  installPhase = ''
    # Fix references from man page https://github.com/lsof-org/lsof/issues/66
    substituteInPlace Lsof.8 \
      --replace ".so ./00DIALECTS" "" \
      --replace ".so ./version" ".ds VN ${version}"
    mkdir -p $out/bin $out/man/man8
    cp Lsof.8 $out/man/man8/lsof.8
    cp lsof $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/lsof-org/lsof";
    description = "A tool to list open files";
    longDescription = ''
      List open files. Can show what process has opened some file,
      socket (IPv6/IPv4/UNIX local), or partition (by opening a file
      from it).
    '';
    license = licenses.purdueBsd;
    maintainers = with maintainers; [ dezgeg ];
    platforms = platforms.unix;
  };
}

{
  lib,
  stdenv,
  makeBinaryWrapper,
  gnugrep,
  graphviz,
  src,
  version,
  # `tatr graph` renders through graphviz's `neato`. Disable to skip the dependency.
  withGraphviz ? true,
}:

stdenv.mkDerivation {
  pname = "tatr";
  inherit version src;

  nativeBuildInputs = [ makeBinaryWrapper ];

  postPatch = ''
    # Make BUILD_TIME reproducible: honour SOURCE_DATE_EPOCH instead of the wall clock.
    substituteInPlace nob.c --replace-warn \
      '    time(&rawtime);' \
      '{ const char *sde = getenv("SOURCE_DATE_EPOCH"); rawtime = sde ? (time_t)atoll(sde) : time(NULL); }'
  '';

  # nob would normally bake in `git rev-parse --short HEAD`, but there is no
  # .git in the Nix sandbox. Feed the locked rev through the compiler wrapper instead.
  env.NIX_CFLAGS_COMPILE = lib.optionalString (src ? shortRev) ''-DGIT_HASH="${src.shortRev}"'';

  buildPhase = ''
    runHook preBuild
    cc -o nob nob.c
    ./nob
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ./nob -test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/tatr $out/bin/tatr
    wrapProgram $out/bin/tatr \
      --prefix PATH : ${lib.makeBinPath ([ gnugrep ] ++ lib.optional withGraphviz graphviz)}
    runHook postInstall
  '';

  meta = {
    description = "Task Tracker - a minimal file-based tasks system and CLI";
    homepage = "https://github.com/tsoding/tatr";
    license = lib.licenses.gpl2Plus;
    mainProgram = "tatr";
    platforms = lib.platforms.linux;
  };
}

# tatr-flake

Nix flake packaging [tsoding/tatr](https://github.com/tsoding/tatr), a file-based
task tracker CLI. Upstream is tracked as a non-flake input, so bumping it is just:

```console
$ nix flake update tatr-src
```

## Usage

```console
$ nix run github:wildwestrom/tatr-flake -- help
```

In another flake:

```nix
inputs.tatr = {
  url = "github:wildwestrom/tatr-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

then either `inputs.tatr.packages.${system}.default` or apply `inputs.tatr.overlays.default`
and use `pkgs.tatr`.

`tatr ref` shells out to `grep` and `tatr graph` to graphviz's `neato`; both are wrapped
into the binary's `PATH`. Pass `withGraphviz = false` to `override` to drop graphviz.

## Notes

- Version is `0-unstable-<date>` (upstream has no tags). `tatr version` reports the locked commit.
- `BUILD_TIME` is pinned to `SOURCE_DATE_EPOCH` so the build is reproducible.
- Linux only, as upstream.

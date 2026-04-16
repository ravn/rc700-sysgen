# Rebuilding the z88dk Docker image from local source

The `z88dk:2.4` image pulled from Docker Hub is a prebuilt release. When
zsdcc (the SDCC backend bundled with z88dk) has a fix in the local
`ravn/z88dk` fork that isn't in the Hub image, rebuild from the local
checkout.

## Command

```bash
cd /Users/ravn/z80/z88dk
docker build -t z88dk:2.4 -f z88dk.Dockerfile .
```

Build time: ~30 minutes on Alpine base.

## To use local changes (not GitHub HEAD)

The default `z88dk.Dockerfile` does `git clone` from GitHub inside the
build. To build from the local checkout with in-progress edits, modify
the Dockerfile to `COPY . /src` (or similar) instead of the `git clone`.
Remember to revert or keep on a branch when done.

## Where

- Local z88dk checkout: `/Users/ravn/z80/z88dk/` (shallow clone of ravn/z88dk)
- Image tag used by all Makefiles in this project: `z88dk:2.4`

## When to rebuild

- After fixing a zsdcc bug in the local fork
- After merging upstream z88dk changes into ravn/z88dk
- If the `sdcc` binary inside the container is crashing on patterns our
  BIOS emits and a workaround exists in the local source

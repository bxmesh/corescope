# BXMesh's fork of CoreScope

This is [Kpa-clawbot/CoreScope](https://github.com/Kpa-clawbot/CoreScope) (GPL-3.0), forked for
BXMesh's CoreScope at corescope.bxmesh.net, only until upstream has the change we need
(cluster-docs: `spec/layout.md`, O292).

## Our patch

Three defaults on the Live page; each viewer can still change any of them, and their choice is kept.

- **Inferred Hops starts off.** Upstream starts it on: when a hop in a packet's path matches no
  node, it draws a made-up grey node between the known hops on either side.
- **Realistic starts on.** Upstream starts it off, drawing each observer's copy of a packet as it
  arrives. On, it holds a packet for `liveMap.propagationBufferMs` (5 s in corescope.bxmesh.net's
  config) to gather every observer's copy, then draws them all together.
- **Multibyte only starts on.** Upstream starts it off. On, a packet whose path uses 1-byte hop
  hashes (or whose hash size can't be read) isn't drawn on the Live page at all: map, feed,
  counters and replays. 1-byte hashes collide too often to place a hop.

The files:
- `public/live.js`: the three defaults, and their boxes.
- `tests/e2e/test-live-multibyte-only-e2e.js`: expects Multibyte only on.
- `tests/unit/test-live.js`: upstream's inferred-hop tests run with it on; nine of ours check the
  defaults and that a viewer's choice holds.

## The branches

- `bxmesh`, the default: an upstream release with our patch on top. `bxmesh/UPSTREAM_RELEASE` names
  the release.
- `master`: upstream's, as forked. Unused.

Upstream's own workflows (its releases, deploys and issue bots) are deleted on `bxmesh`; ours are
`.github/workflows/bxmesh-*`.

## The image

A merge to `bxmesh` builds `ghcr.io/bxmesh/corescope:<release>-bxmesh` (and `:sha-<commit>`) with
upstream's own Dockerfile. `corescope.bxmesh.net` builds on it, pinned by digest, and Renovate opens
the bump there. BXMesh never deploys itself: the owner merges and syncs (O14).

## A new upstream release

1. Each morning the `upstream` workflow opens an issue when upstream has a release we haven't merged.
2. Read its changelog. If upstream now has all three defaults, or settings for them, stop here and
   retire the fork (below).
3. `bxmesh/sync.sh vX.Y.Z` merges it into a new branch, `upstream-vX.Y.Z`, keeps upstream's
   workflows out, records the release and runs the tests. Push it and open a pull request to
   `bxmesh` with the changelog, risks and rollback; the owner merges it.
4. The build pushes the image; Renovate's pull request in `corescope.bxmesh.net` follows.

## Retiring the fork

When upstream has all three: point `corescope.bxmesh.net`'s Dockerfile back at
`ghcr.io/kpa-clawbot/corescope`, archive this repo, and take its row out of the layout.

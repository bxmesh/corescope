# BXMesh's fork of CoreScope

This is [Kpa-clawbot/CoreScope](https://github.com/Kpa-clawbot/CoreScope) (GPL-3.0), forked for
BXMesh's CoreScope at corescope.bxmesh.net, only until upstream has the one change we need
(cluster-docs: `spec/layout.md`, O292).

## Our patch

On the Live page, **Inferred Hops** starts off. Upstream starts it on: when a hop in a packet's path
matches no node, it draws a made-up grey node between the known hops on either side. A viewer who
turns it on keeps it on; one who has never touched it doesn't see them. Nothing else changes.

- `public/live.js`: the default, and the box unticked.
- `tests/unit/test-live.js`: upstream's tests of inferred hops run with it on; three of ours check
  the default.

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
2. Read its changelog. If upstream now starts Inferred Hops off, or has a setting for it, stop
   here and retire the fork (below).
3. `bxmesh/sync.sh vX.Y.Z` merges it into a new branch, `upstream-vX.Y.Z`, keeps upstream's
   workflows out, records the release and runs the tests. Push it and open a pull request to
   `bxmesh` with the changelog, risks and rollback; the owner merges it.
4. The build pushes the image; Renovate's pull request in `corescope.bxmesh.net` follows.

## Retiring the fork

When upstream has the change: point `corescope.bxmesh.net`'s Dockerfile back at
`ghcr.io/kpa-clawbot/corescope`, archive this repo, and take its row out of the layout.

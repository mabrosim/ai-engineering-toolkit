# Public Release Checklist

Use this checklist before making any content public (GitHub, blog, portfolio).

Resolve applicability under the [Public Safety Guide](../docs/public-safety.md#scope)
and governing host release guidance. Unrelated host releases use host release
criteria and the mandatory safety baseline, plus applicable generic checks below.
Keep applicability evidence and justified `N/A` reasons outside gate packets;
unknown applicability is unresolved, not `N/A`, and mandatory safety cannot be
waived.

---

## Content Review

- [ ] NDA Safety Checklist passed (see [nda-safety-checklist.md](nda-safety-checklist.md))

---

## Code Quality

- [ ] Code is linted and formatted
- [ ] Tests pass
- [ ] No dead code or debug artifacts
- [ ] No `TODO` comments with sensitive context
- [ ] No commented-out code blocks left in place

---

## Documentation

- [ ] README exists and is accurate
- [ ] Usage examples are clear and runnable
- [ ] Dependencies are documented
- [ ] License is present and appropriate

---

## Repository Hygiene

- [ ] `.gitignore` covers secrets and local config files
- [ ] No large binary files committed
- [ ] No `.env` or config files with real values
- [ ] Commit history does not contain sensitive information

---

## Final Steps

- [ ] Reviewed by a second person or re-read after 24 hours
- [ ] Repository visibility confirmed (public vs private)
- [ ] License chosen and added

---

## Signed AET Distribution (tagged AET bundle releases only)

All checks in this section are required for a tagged AET bundle release. For
other work, including unrelated host releases, mark this section `N/A` with the
trigger evidence retained outside gate packets; do not waive individual checks
for an applicable AET release.

- [ ] Release tag matches strict `vX.Y.Z` semver; no pre-release suffix
- [ ] `CHANGELOG.md` contains the curated section used as the release notes
- [ ] Release workflow (`.github/workflows/release.yml`) triggered on the tag and completed successfully
- [ ] Exactly four assets uploaded: `aet-bundle-<v>.tar.gz`, `aet-bundle-<v>.sha256`, `aet-bundle-<v>.tar.gz.cosign.bundle`, `aet-bundle-<v>.sha256.cosign.bundle`
- [ ] `aet-bundle-<v>.sha256.cosign.bundle` present and cosign verifies the checksum file
- [ ] `aet-bundle-<v>.tar.gz.cosign.bundle` present and cosign verifies the tarball
- [ ] Certificate SAN for both bundles is `https://github.com/mabrosim/ai-engineering-toolkit/.github/workflows/release.yml@refs/tags/<v>` (exact, not a regexp)
- [ ] `scripts/build-release.sh <v>` reproduces a tarball whose SHA-256 matches `aet-bundle-<v>.sha256` when run on Linux with GNU tar
- [ ] Release marked non-prerelease on GitHub; no draft status

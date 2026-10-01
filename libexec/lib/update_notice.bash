# Sourced by libexec/dune-update: whether the hourly update check should announce Steam's build. Pure (no I/O).
# update_notice_due INSTALLED LATEST LAST_NOTIFIED: success when both builds are known, they differ (players' clients
# auto-update to Steam's build and then cannot join an older server) and LATEST is not the build announced last, so a
# build is announced once, not every hour, and every newer build again.
update_notice_due() {
	local installed=$1 latest=$2 last=$3
	[ -n "$installed" ] && [ -n "$latest" ] && [ "$installed" != "$latest" ] && [ "$latest" != "$last" ]
}

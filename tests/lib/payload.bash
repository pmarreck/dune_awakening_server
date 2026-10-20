# Sourced by payload suites. The game database name the way Funcom's services derive it from a payload root:
# "dune_" + the stream branch in DuneSandbox/Config/perforce-keywords.json with dots and dashes as underscores
# (//seabass/sb-1.5.15.0/ -> dune_sb_1_5_15_0). It changes with the game version, so suites must not hardcode it.
payload_db_name() {
	jq -r '.path' "$1/DuneSandbox/Config/perforce-keywords.json" | sed -E 's#.*//seabass/([^/]+)/.*#\1#; s/[-.]/_/g; s/^/dune_/'
}

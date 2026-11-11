# Sourced by libexec/dune-doctor and libexec/dune-update: the Funcom (FLS) token's expiry and when the scheduled check
# announces it. Only fls_token_exp reads a file; the rest is pure.

# fls_token_exp FILE: print the token's exp claim (Unix seconds). The token is a JWT: its payload is base64url without
# padding. Fails when the file is unreadable or the claim is not a number.
fls_token_exp() {
	local payload exp
	payload=$(tr -d '\r\n' < "$1" 2>/dev/null | cut -d. -f2 | tr '_-' '/+') || return 1
	[ -n "$payload" ] || return 1
	while [ $(( ${#payload} % 4 )) -ne 0 ]; do payload="$payload="; done
	exp=$(base64 -d <<<"$payload" 2>/dev/null | jq -r '.exp // empty' 2>/dev/null)
	[[ "$exp" =~ ^[0-9]+$ ]] || return 1
	printf '%s\n' "$exp"
}

# token_notice_stage SECONDS_LEFT: print 30 (under 30 days left), 7 (under 7 days) or expired (none left); nothing
# while 30 days or more remain.
token_notice_stage() {
	local left=$1
	if [ "$left" -le 0 ]; then echo expired
	elif [ "$left" -lt $((7 * 86400)) ]; then echo 7
	elif [ "$left" -lt $((30 * 86400)) ]; then echo 30
	fi
}

# token_notice_due EXP STAGE LAST_NOTIFIED: success when there is a stage and it was not the last one announced for
# this token (LAST_NOTIFIED is EXP:STAGE), so each stage goes out once per token and a renewed token starts over.
token_notice_due() {
	local exp=$1 stage=$2 last=$3
	[ -n "$stage" ] && [ "$exp:$stage" != "$last" ]
}

# shellcheck shell=bash
# pick_port_base N [LO HI]: print a base port such that base..base+N-1 lie within LO..HI (default 20000..32767)
# and none has a TCP/UDP listener. The default stays below Funcom's Int16 port limit (32767) and below Linux's
# ephemeral range (32768+). Fails (status 1) when no free block is found.
pick_port_base() {
	local n=$1 lo=${2:-20000} hi=${3:-32767} base p busy tries=0 span
	command -v ss >/dev/null || { printf 'pick_port_base: ss (iproute2) not found\n' >&2; return 2; }
	span=$((hi - lo - n + 2))
	[ "$span" -ge 1 ] || return 1
	while [ "$tries" -lt 200 ]; do
		tries=$((tries + 1))
		base=$((lo + RANDOM % span))
		busy=0
		for ((p = base; p < base + n; p++)); do
			if ss -Hltun "sport = :$p" | grep -q .; then busy=1; break; fi
		done
		[ "$busy" -eq 0 ] && { printf '%s\n' "$base"; return 0; }
	done
	return 1
}

# stop_epmd PORT: stop the Erlang port mapper a test started on PORT (found by listener, since epmd itself is not
# on the operator shell's PATH) and report whether the port is free afterwards.
stop_epmd() {
	local port=$1 pid
	pid=$(ss -Hltnp "sport = :$port" | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)
	[ -n "$pid" ] && kill "$pid" 2>/dev/null
	for _ in $(seq 1 40); do ss -Hltn "sport = :$port" | grep -q . || return 0; sleep 0.1; done
	return 1
}

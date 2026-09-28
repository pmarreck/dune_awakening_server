# shellcheck shell=bash
# Helpers for tests that feed a real game broker (libexec/dune-rabbitmq, broker "game") the way the game does.
# rabbitmqctl may print locale warnings around an eval's result, so results are matched by a marker.

# declare_exchange NAME TYPE: a durable exchange, as Funcom's TextRouter declares chat.intercept (topic).
declare_exchange() {
	local out
	out=$(libexec/dune-rabbitmq ctl game eval "{ok, _} = rabbit_exchange:declare(rabbit_misc:r(<<\"/\">>, exchange, <<\"$1\">>), $2, true, false, false, [], <<\"test\">>), io:format(\"declared=ok~n\")." 2>&1)
	[[ "$out" == *declared=ok* ]] || { printf 'declare_exchange: %s\n' "$out" >&2; return 1; }
}

# publish_chat EXCHANGE ROUTING_KEY USER_ID BODYFILE: publish BODYFILE's bytes with AMQP property user_id (empty: none),
# as RabbitMQ does for a client whose connection user is USER_ID. Fails unless the publish is ok.
publish_chat() {
	local uid=undefined out
	[ -n "$3" ] && uid="<<\"$3\">>"
	out=$(libexec/dune-rabbitmq ctl game eval "XName = rabbit_misc:r(<<\"/\">>, exchange, <<\"$1\">>), X = rabbit_exchange:lookup_or_die(XName), {ok, Body} = file:read_file(\"$4\"), P = {list_to_atom(\"P_basic\"), <<\"application/json\">>, undefined, [], 1, undefined, undefined, undefined, undefined, undefined, undefined, undefined, $uid, undefined, undefined}, Content = rabbit_basic:build_content(P, Body), {ok, Msg} = rabbit_basic:message(XName, <<\"$2\">>, Content), io:format(\"publish=~p~n\", [rabbit_queue_type:publish_at_most_once(X, Msg)])." 2>&1)
	[[ "$out" == *publish=ok* ]] || { printf 'publish_chat: %s\n' "$out" >&2; return 1; }
}

# text_chat SENDER_FUNCOM_ID CHANNEL MESSAGE X Y Z: a TextChat body as the client sends it to chat.intercept.
text_chat() {
	local inner
	inner=$(jq -cn --arg from "$1" --arg ch "$2" --arg m "$3" --argjson x "$4" --argjson y "$5" --argjson z "$6" \
		'{m_Id: "0123456789abcdef0123456789abcdef", m_ChannelType: $ch, m_bUseSpoofedUserName: false, m_FuncomIdFrom: $from,
		  m_UserNameTo: "", m_Message: {m_UnlocalizedMessage: $m, m_LocalizedMessage: {m_TableId: "", m_Key: "", m_FormatArgs: []}},
		  m_Timestamp: "2026.09.28-02.33.56", m_OriginLocation: {X: $x, Y: $y, Z: $z}, m_HasSeenMessage: false}')
	jq -cn --arg c "$inner" '{content: $c, Type: "TextChat"}'
}

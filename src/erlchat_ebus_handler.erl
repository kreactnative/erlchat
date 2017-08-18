-module(erlchat_ebus_handler).
-export([handle_msg/2]).

handle_msg(Msg, Context) ->
    io:format("handle_msg started!~n"),
    Context ! {message_publised, Msg}.

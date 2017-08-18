%%%-------------------------------------------------------------------
%% @doc erlchat public API
%% @end
%%%-------------------------------------------------------------------

-module(erlchat_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
  Port=5059,
  Dispatch = cowboy_router:compile([
      {'_', [
          {"/", cowboy_static, {file, "priv/index.html"}},
          {"/websocket", erlchat_ws_handler, []},
          {"/assets/[...]", cowboy_static, {dir, "priv/assets"}}
      ]}
  ]),
  {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
		env => #{dispatch => Dispatch}
	}),
  io:format("Start Server : http://localhost:~w ~n",[Port]),
  erlchat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

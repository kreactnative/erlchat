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
  Dispatch = cowboy_router:compile([
      {'_', [
          {"/", cowboy_static, {file, "priv/index.html"}},
          {"/assets/[...]", cowboy_static, {dir, "priv/assets"}}
      ]}
  ]),

  {ok, _} = cowboy:start_clear(http, 100, [{port, 5059}],
          #{env => #{dispatch => Dispatch}}
    ),
    erlchat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

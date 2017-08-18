-module(erlchat_ws_handler).

%% API
-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2, websocket_terminate/3]).

-define(CHATROOM_NAME, ?MODULE).
%% innactivity timeout
-define(TIMEOUT, 5 * 60 * 1000).

-record(state, {name, handler}).

init(Req, Opts) ->
%%    io:format("init(req, opts)~n~n"),
    {cowboy_websocket, Req, Opts}.


websocket_init(State) ->
%%    io:format("websocket started!~n"),
    Handler = ebus_proc:spawn_handler(fun erlchat_ebus_handler:handle_msg/2, [self()]),
    ebus:sub(Handler, ?CHATROOM_NAME),
    {ok, #state{name = get_name(), handler=Handler}}.

websocket_handle({text, Msg}, State) ->
    ebus:pub(?CHATROOM_NAME, {State#state.name, Msg}),
    {ok,State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({message_publised, {Sender, Msg}}, State) ->
    io:format("Sender ~w~n",[Sender]),
    io:format("message ~w ~n",[Msg]),
    {reply, {text,
      jsx:encode([{<<"sender">>,Sender}, {<<"msg">>, Msg}])
    }, State};
websocket_info(_Info, State) ->
    {ok, State}.

websocket_terminate(_Reason, _Req, State) ->
    ebus:unsub(State#state.handler, ?CHATROOM_NAME),
    ok.

get_name() ->
    %%  시드 초기화
    {A1, A2, A3} = now(),
    random:seed(A1, A2, A3),

%% 1~10000까지 숫자 중 하나를 랜덤 선택
    Num = rand:uniform(10000),
    List = io_lib:format("~p", [Num]),
    Name = list_to_binary(lists:append(List)),
    Name.

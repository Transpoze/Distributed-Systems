%Addi Djikic, addi@kth.se, ID2201 - RUDY
-module(rudy).
-export([init/1,start/1, stop/0]).

%Start Rudy
start(Port) ->
	register(rudy, spawn(fun() -> init(Port) end)).

%*****************************************************

init(Port) -> %%Port could be local host:8080
	Opt = [list, {active, false}, {reuseaddr, true}], %List of integers and npt binary structure
	case gen_tcp:listen(Port, Opt) of
		{ok, Listen} ->
			handler(Listen), %%Here we will pass the socket to the handler
 			gen_tcp:close(Listen),
			ok;
		{error, Error} ->
			error
	end.
%*****************************************************
handler(Listen) ->
	case gen_tcp:accept(Listen) of  %%accept(ListenSocket) -> {ok, Socket} | {error, Reason}
		{ok, Client} ->
			request(Client), %%Pass client to request
			gen_tcp:close(Client), %%When request is handled the connect is closed
			handler(Listen),
			ok;
		{error, Error} ->
			error
	end.
%*****************************************************
request(Client) ->
	Recv = gen_tcp:recv(Client, 0), %%Receive takes Socket + Length = 0 (All bytes)
	case Recv of
		{ok, Str} ->
			Request = http:parse_request(Str),
			Response = reply(Request),
			gen_tcp:send(Client, Response);
		{error, Error} ->
			io:format("rudy: error: ~w~n", [Error])
	end,
	gen_tcp:close(Client).
%*****************************************************	
reply({{get, URI, _}, _, _}) ->
	timer:sleep(40),
	http:ok("SUCCESSFULLY! HTTP 200 ELITE").

%*****************************************************

%Terminate Rudy
stop() ->
	exit(whereis(rudy), "time to die").

%*****************************************************
%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(routy).
-export([start/2, stop/1]).


start(Reg, Name) ->
	register(Reg, spawn(fun() -> init(Name) end)). %To keep terminal running

%%%%-------------------------------------------------------------------------

stop(Node) ->
	Node ! stop,
	unregister(Node).

%%%%-------------------------------------------------------------------------

init(Name) ->
	Intf = intf:new(),
	Map = map:new(),
	Table = dijkstra:table(Intf, Map),
	Hist = hist:new(Name),
	router(Name, 0, Hist, Intf, Table, Map).

%%%%-------------------------------------------------------------------------



router(Name, N, Hist, Intf, Table, Map) ->
	receive

	{add, Node, Pid} ->
		Ref = erlang:monitor(process,Pid),
		Intf1 = intf:add(Node, Ref, Pid, Intf),
		router(Name, N, Hist, Intf1, Table, Map);

	{remove, Node} ->
		{ok, Ref} = intf:ref(Node, Intf),
		erlang:demonitor(Ref),
		Intf1 = intf:remove(Node, Intf),
		router(Name, N, Hist, Intf1, Table, Map);

		{'DOWN', Ref, process, _, _} ->
		{ok, Down} = intf:name(Ref, Intf),
		io:format("~w: exit recived from: ~w~n", [Name, Down]),
		Intf1 = intf:remove(Down, Intf),
		router(Name, N, Hist, Intf1, Table, Map);


	{status, From} ->
		From ! {status, {Name, N, Hist, Intf, Table, Map}},
		router(Name, N, Hist, Intf, Table, Map);


	%%%%-------------------------------------------------------------------------


	%Link-state message
	{links, Node, R, Links} ->
		case hist:update(Node, R, Hist) of
			{new, Hist1} ->
				intf:broadcast({links, Node, R, Links}, Intf),
				Map1 = map:update(Node, Links, Map),
				io:format("New: ~s ~n", [Name]),
				router(Name, N, Hist1, Intf, Table, Map1);
					old ->
				io:format("Old: ~s ~n", [Name]),
				router(Name, N, Hist, Intf, Table, Map)
		end;

	%%%%-------------------------------------------------------------------------

	%Will send to order the router to update its routing table
	update ->
		Table1 = dijkstra:table(intf:list(Intf), Map),
		router(Name, N, Hist, Intf, Table1, Map);

	%%%%-------------------------------------------------------------------------

	%manually can order our router to broadcast a link-state message.
	broadcast ->
		Message = {links, Name, N, intf:list(Intf)},
		intf:broadcast(Message, Intf),
		router(Name, N+1, Hist, Intf, Table, Map);	

	%%%%-------------------------------------------------------------------------


	{route, Name, From, Message} ->
		io:format("~w: received message: ~s ~n", [Name, Message]),
		router(Name, N, Hist, Intf, Table, Map);

	%%%%-------------------------------------------------------------------------

	%Drop package
	{route, To, From, Message} ->
		io:format("~w: routing message: ~s ~n", [Name, Message]),
		case dijkstra:route(To, Table) of
			{ok, Gw} ->
			case intf:lookup(Gw, Intf) of
				{ok, Pid} ->
				io:format("~w Going Through: ~w~n", [Name,Gw]),
				Pid ! {route, To, From, Message};
			notfound ->
				ok
			end;
		notfound ->
			ok
		end,
	router(Name, N, Hist, Intf, Table, Map);

	%%%%-------------------------------------------------------------------------


	%Add a message so that a local user can initiate the routing of a message without knowing the name of the local router.
	{send, To, Message} ->
		self() ! {route, To, Name, Message},
		router(Name, N, Hist, Intf, Table, Map);


	stop ->
		ok
end.


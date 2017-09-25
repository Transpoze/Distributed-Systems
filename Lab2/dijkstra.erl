%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(dijkstra).
-export([route/2,table/2]).
%Computes the routing table: 

%[{berlin,madrid},{rome,paris},{madrid,madrid},{paris,paris}]
%This table says that if we want to send something to berlin we should
%send it to madrid. Note that we also include information that in order to
%reach madrid we should send the message to madrid.

%%%%-------------------------------------------------------------------------

%returns the length of the shortest path to the node or 0 if the node is not found.
entry(Node, Sorted) -> 
	SearchedNode = lists:keyfind(Node,1,Sorted),

	case SearchedNode of

		{FROMTHIS, HOPS, TOTHIS} -> HOPS; %Hops is length in this case

		false -> 0 %If it cannot be found
	end.

%%%%-------------------------------------------------------------------------

%Replaces the entry for Node in Sorted with a new entry having a new length N and Gateway. 
%The resulting list should of course be sorted.
replace(Node, N, Gateway, Sorted) -> 

	%Returns the rest of the sorted list, but with adding the Node back again first and the length and gateway
	UpdatedENTRY = [{Node,N,Gateway}|lists:keydelete(Node,1,Sorted)], 

	%Sort by the second element, length
	SortedCompleteEntry = lists:keysort(2,UpdatedENTRY),
	SortedCompleteEntry. 

%%%%-------------------------------------------------------------------------


%Update the list Sorted given the information that Node can be reached in N hops using Gateway.
%If no entry is found then no new entry is added. Only if we have a better (shorter) path should we replace the existing entry.
update(Node, N, Gateway, Sorted) ->
	
	ShortestHOPS = entry(Node, Sorted),
    if 
		N < ShortestHOPS -> %If the length is smaller, update the entry

	    	replace(Node,N,Gateway,Sorted);

		true -> Sorted %Else we return the list before with no change
    end.

%%%%-------------------------------------------------------------------------


%construct a table given a sorted list of nodes, a map and a table constructed so far.
iterate(Sorted, Map, Table) ->

    case Sorted of
		[] -> Table; %If there are no more entries in the sorted list, return the table

		[{FromHere,inf,ToHere} | _] -> Table; %If the first entry is a dummy entry with an infinite path to a city we know that the rest of the sorted list is also of infinite length

		%Otherwise, take the first entry in the sorted list, find the nodes in the
		%map reachable from this entry and for each of these nodes update the Sorted list.
		%The entry that you took from the sorted list is added to the routing table
		[CurrEntry | FollowedLinks] ->
	    {TheNode,HopsBetween,Gateway} = CurrEntry,
		ReachableLinks = map:reachable(TheNode,Map),
		NewSortList = lists:foldl(
		fun(ForEachNodes,PathsToLookFor) ->	
			update(ForEachNodes,HopsBetween+1,Gateway,PathsToLookFor) %Check if the new possible path is cheeper
		end, 
		FollowedLinks, ReachableLinks), %FollowedLinks is retured if REachableLinks is empty


	    iterate(NewSortList,Map,[{TheNode,Gateway} | Table]) %Itterate and add to table until all ReachableLinks are iterated through
    end.	

%%%%-------------------------------------------------------------------------

table(Gateways, Map) ->
	
	%firstly we need all nodes from the Map
	ListOfNodes = map:all_nodes(Map),

	%InitList should have dummy nodes with inf and gateway unknown, length zero for the gateways

	InitList = lists:keysort(2, lists:map(
		fun(Node) ->
			TrueIfElementFound = lists:member(Node, Gateways), %Returns true of Node is found in gateway
			%Set the dummys for the init list and sort them. 
			case TrueIfElementFound of
				true ->
					{Node, 0, Node};
				false ->
					{Node, inf, unknown}
			end
		end, ListOfNodes)),

	iterate(InitList, Map, []). %Generate the table from iterate with a dummy table as input

%%%%-------------------------------------------------------------------------

%Search the routing table and return the gateway suitable to route messages to a node.
%If a gateway is found we should return {ok, Gateway} otherwise we return 'notfound'.
route(Node, Table) -> 

	FindGate = lists:keyfind(Node,1,Table),

	case FindGate of
		{FromNode,Gateway} ->
			{ok, Gateway};
		false -> 
			notfound
	end.

%%%%-------------------------------------------------------------------------

















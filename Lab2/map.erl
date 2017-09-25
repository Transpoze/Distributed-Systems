%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(map).
-export([new/0,update/3,reachable/2,all_nodes/1]).%,reachable/2,all_nodes/1]).

%returns an empty map (a empty list)
new() ->
	[].
%%%%-------------------------------------------------------------------------

%Updates the Map to reflect that Node has directional links to all nodes in the list Links. 
%The old entry is removed.
update(Node, Links, Map) ->	
	UPDATED_MAP = lists:keydelete(Node, 1, Map), %delete the first element that match with Node
	[{Node, Links} | UPDATED_MAP].

%%%%-------------------------------------------------------------------------

%returns the list of nodes directly reachable from Node.
reachable(Node, Map) ->
	Nodes_Reached = lists:keyfind(Node,1,Map), %searches the list whos Nth element compares to Node, returns list if found. 
	case Nodes_Reached of   %Example: [{berlin,[london,paris]},{SomethingElse,[london,paris]}},{Berlin}]]
			
		{Node,ReachableNodes} -> ReachableNodes; %If we have this structure from map, found the reachable key, we return the reachable nodes

		false -> [] %Handle if empty
	
    end.

%%%%-------------------------------------------------------------------------

%Returns a list of all nodes in the map, also the ones
%without outgoing links. So if berlin is linked to london but london
%does not have any outgoing links (and thus no entry in the list), london
%should still be in the returned list
 all_nodes(Map) ->
	%usort sorts the list and removes duplicates of elements, flatten makes the map to a list from deeplist, map itterates the func in the list
	ReturnAllNodes = lists:usort(lists:flatten(lists:map(
		fun(Ittr) ->
			case Ittr of
				{FirstNode,RestOfList} -> [FirstNode|RestOfList]
			end
		end,
		Map))),
	ReturnAllNodes.

%%%%-------------------------------------------------------------------------




	


%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(hist).
-export([new/1,update/3]).


%Return a new history, where messages from Name will always be seen as old.
new(Name) ->
	[{Name,0}]. %We set a list for Name and begin at 0 due to new list

%%%%-------------------------------------------------------------------------

%Check if message number N from the Node is old or new. 
%If it is old then return old but if it new return {new, Updated} where Updated is the updated history.
update(Node, N, History) ->

	NodesInHistory = lists:keyfind(Node,1,History),

	case NodesInHistory of
		{_,MessageNumber} ->
	   
	    if
			N > MessageNumber -> %Only keep track of the highest number of the counter
				{new, [{Node,N} | lists:keydelete(Node, 1, History)]}; %Return new and updated history by removing old

			true  -> old
	    end;
	    false ->
	    	{new, [{Node,N} | lists:keydelete(Node, 1, History)]}
	end.

%%%%-------------------------------------------------------------------------
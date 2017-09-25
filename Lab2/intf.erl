%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(intf).
-export([new/0,add/4,lookup/2,remove/2,ref/2,name/2,list/1,broadcast/2]).

%A interface is described by the symbolic name (london), a process reference and a process identifier

%Return an empty set of interfaces.
new() ->
	[].

%%%%-------------------------------------------------------------------------

%Add a new entry to the set and return the new set of interfaces.
add(Name, Ref, Pid, Intf) ->
	CheckElementsInIntf = lists:member({Name, Ref, Pid}, Intf),
	case CheckElementsInIntf of
		true ->
	    	Intf;
		false ->
	    	[{Name, Ref, Pid} | Intf]
    end.

%%%%-------------------------------------------------------------------------

%Remove an entry given a name of an interface, return a new set of interfaces.
remove(Name, Intf) ->
	lists:keydelete(Name,1,Intf).

%%%%-------------------------------------------------------------------------

%Find the process identifier given a name, return {ok, Pid} if found otherwise notfound.
lookup(Name, Intf) ->
	FindPid = lists:keyfind(Name,1,Intf),

	case FindPid of
		{Name,PR,Pid} ->
			{ok,Pid};
		false ->
			notfound
	end.

%%%%-------------------------------------------------------------------------

%Find the reference given a name and return {ok,Ref} or notfound.
ref(Name, Intf) ->
	FindRef = lists:keyfind(Name,1,Intf),

	case FindRef of
		{_,Ref,_} ->
			{ok, Ref};
		false ->
			notfound
	end.

%%%%-------------------------------------------------------------------------

%Find the name of an entry given a reference and return {ok, Name} or notfound.
name(Ref, Intf) ->
	FindEntryName = lists:keyfind(Ref,2,Intf), %The reference is on the second pos

	case FindEntryName of

		{Name, Ref, Pid} ->
	    	{ok, Name};

		false ->
	    	notfound
    end.

%%%%-------------------------------------------------------------------------

%Return a list with all names.
list(Intf) ->
	ReturnList = lists:map(

		fun(IterThrough) ->
			case IterThrough of
				{Name,Ref,Pid} -> Name
			end
		end,

	Intf),
	ReturnList.

%%%%-------------------------------------------------------------------------

%Send the message to all interface processes.
broadcast(Message, Intf) -> 
	
	%Return list if Pids
	ListOfProc = lists:map(
			fun(ItrrIntf) ->

				case ItrrIntf of
					{Name,Ref,Pid} -> {Name,Ref,Pid ! Message}
				end
			end,
		Intf),
	ListOfProc.

%%%%-------------------------------------------------------------------------














	







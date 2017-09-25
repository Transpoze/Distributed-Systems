%Addi Djikic, addi@kth.se, ID2201 - ROUTY
-module(testMyRouty).
-export([startRoutingNodes/1,broadcast/0,update/0,send/0,remove/0,stop/0]).

%%This test script sets up the processes and all around the routers to be able to send messages

startRoutingNodes(ProcessIdentifier) ->
    routy:start(stockholm, sweden),
    routy:start(sarajevo, bosnia),
    routy:start(london, uk),
    routy:start(washington,usa),

   stockholm ! {add, usa, {washington, ProcessIdentifier}},
   stockholm ! {add, bosnia, {sarajevo, ProcessIdentifier}},
   washington ! {add, bosnia , {sarajevo, ProcessIdentifier}},
   sarajevo ! {add, uk, {london, ProcessIdentifier}},
   london ! {add, sweden, {stockholm, ProcessIdentifier}}.
%%%%-------------------------------------------------------------------------

%broadcast to all links
broadcast()->
    stockholm ! broadcast, 
    washington ! broadcast, 
    sarajevo ! broadcast,
    london ! broadcast. 
%%%%-------------------------------------------------------------------------

% update routing table, dijkstra find shortest gateway path
update()->
    stockholm ! update, 
    washington ! update,
    sarajevo ! update,
    london ! update.

%%%%-------------------------------------------------------------------------

%send()->
     %washington ! {send, sweden, "From DC: What happen in Sweden last friday?!? - Trump"},
     %timer:sleep(500),
     %stockholm ! {send, usa, "From Stockholm: Ehhmm... We danced like small frogs?"}.

   send()->
        stockholm ! {send, bosnia, "Hi Sarajevo! Whats happening!? - Stockholm"},
        timer:sleep(500),
        sarajevo ! {send, sweden, "Nothing you know, just chillin - Sarajevo"}.

    %Send between terminals
    %send()->
        %stockholm ! {send, uk, "Does sending it via another terminal work? - Stockholm"},
        %timer:sleep(500),
        %london ! {send, sweden, "Yes, looks like it, just got your text. - London"}.
%%%%-------------------------------------------------------------------------
    remove() ->
        stockholm ! {remove, bosnia}. 


%%%%-------------------------------------------------------------------------

stop()-> %Close all the nodes in the network
    stockholm ! stop,
    washington ! stop,
    sarajevo ! stop,
    london ! stop.
%%%%-------------------------------------------------------------------------
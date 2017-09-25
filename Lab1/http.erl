%Addi Djikic, addi@kth.se, ID2201 - RUDY
-module(http).
-export([parse_request/1,ok/1,get/1]).

%We will only parse the http request
parse_request(R0) ->
	{Request, R1} = request_line(R0),
	{Headers, R2} = headers(R1),
	{Body, _} = message_body(R2),
	{Request, Headers, Body}. %<-- The parsed result

%*****************************************************

%The Request-Line begins with a method token, followed by the
 %  Request-URI and the protocol version, and ending with CRLF.

request_line([$G, $E, $T, 32 |R0]) ->  %Parse until GET *Space* 
	{URI, R1} = request_uri(R0),
	{Ver, R2} = http_version(R1),
	[13,10|R3] = R2,
	{{get, URI, Ver}, R3}. %First element is the parsed representation of the requested line
						   %R3 is the rest of the string

%*****************************************************

request_uri([32|R0])->  
	{[], R0};
request_uri([C|R0]) ->
	{Rest, R1} = request_uri(R0),
	{[C|Rest], R1}. %Returns the dirs + the rest

%*****************************************************
http_version([$H, $T, $T, $P, $/, $1, $., $1 | R0]) ->  
	{v11, R0};
http_version([$H, $T, $T, $P, $/, $1, $., $0 | R0]) ->
	{v10, R0}.
%*****************************************************

%One that consumes a sequence of headers and one that consumes individual headers
headers([13,10|R0]) ->
	{[],R0};
headers(R0) ->
	{Header, R1} = header(R0),
	{Rest, R2} = headers(R1),
	{[Header|Rest], R2}.

header([13,10|R0]) ->
	{[], R0};
header([C|R0]) ->
	{Rest, R1} = header(R0),
	{[C|Rest], R1}.
%*****************************************************

message_body(R) ->
{R, []}.

%*****************************************************
%Generate a request
ok(Body) ->
	"HTTP/1.1 200 OK\r\n" ++ "\r\n" ++ Body.
%*****************************************************
%
get(URI) ->
	"GET " ++ URI ++ " HTTP/1.1\r\n" ++ "\r\n".
%*****************************************************

%>http:parse_request("GET /'URI' HTTP/'Version'\r\n'Header' 34\r\n\r\n'Body'").


-module(mod_presence_redis).
-author('ptevans@gmail.com').

-behaviour(gen_mod).

-export([start/2,
         stop/1,
         set_presence/4,
         unset_presence/4]).

-include("ejabberd.hrl").

start(Host, _Opts) ->
    ?INFO_MSG("Starting mod_presence_redis for ~p~n", [Host]),
    Conn = c(),
    clear_presence(Conn, Host),
    eredis_client:stop(Conn),
    ejabberd_hooks:add(set_presence_hook, Host, ?MODULE, set_presence, 75),
    ejabberd_hooks:add(unset_presence_hook, Host, ?MODULE, unset_presence, 75),
    ok.

stop(Host) ->
    Conn = c(),
    clear_presence(Conn, Host),
    eredis_client:stop(Conn),
    ok.

set_presence(User, Host, _Resource, _Presence) ->
    Conn = c(),
    add_user_host(Conn, Host, User),
    eredis_client:stop(Conn),
    ok.

unset_presence(User, Host, _Resource, _Status) ->
    Conn = c(),
    remove_user_host(Conn, Host, User),
    eredis_client:stop(Conn),
    ok.

c() ->
    {ok, C} = eredis:start_link(),
    C.

add_user_host(C, Host, User) ->
    {ok, Values} = eredis:q(C, ["sadd", Host++":online_users", User]),
    case Values == <<"1">> of
        true -> eredis:q(C, ["publish", Host++":events", User++":login"]);
        false -> ok
    end,
    ok.

remove_user_host(C, Host, User) ->
    {ok, Values} = eredis:q(C, ["srem", Host++":online_users", User]),
    case Values == <<"1">> of
        true -> eredis:q(C, ["publish", Host++":events", User++":logout"]);
        false -> ok
    end,
    ok.

clear_presence(C, Host) ->
    {ok, _} = eredis:q(C, ["del", Host++":online_users"]),
    ok.



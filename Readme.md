## General
mod_presence_redis is an Ejabberd module that exports presence data to Redis. When a user logs into the server, their username is added to a set in Redis. When they logout it is removed. Additionally login and logout events are published to a Redis pubsub channel on a per domain basis.

## Usage Example
The presence set key is "\<domain\>:online_users". If I login as test1@localhost, the set localhost will have test1 added to it:

```
smembers localhost:online_users
*1
$5
test1
```

To receive these event in realtime, subscribe to the key "\<domain\>:events":

```
subscribe localhost:events
*3
$9
subscribe
$13
localhost:events
:1
*3
$7
message
$13
localhost:events
$11
test1:login
*3
$7
message
$13
localhost:events
$12
test1:logout
```

## How to Build
mod_presence_redis was developed and tested against Ejabberd 2.1.11.

The build script expects that you've checked out this repository inside of the ejabberd-modules repo.


waitingRole.
start.
firstPoint(7,33).
secondPoint(33,33).
thirdPoint(33,7).
fourthPoint(8,7).


moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.


+step(_): thing(X,Y,dispenser,Type) & task(task4,_,_,[req(_,_,RequestedType),_]) & position(A,B) & Type==RequestedType & not found
    <- +found;
    .send("agentA1", tell, dispenser(X+A,Y+B,Type));
    skip.
+step(_): thing(X,Y,dispenser,Type) & task(task4,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & not found
    <- +found;
    .send("agentA2", tell, dispenser(X+A,Y+B,Type));
    skip.

+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .broadcast(tell, roleDestination(A+X, B+Y));
    skip.

+step(_): moving(w)
    <- !moveW.
+step(_): moving(e)
    <- !moveE.
+step(_): moving(n)
    <- !moveN.
+step(_): moving(s)
    <- !moveS.


+step(_): not roleDestination(X,Y)
    <- skip.
+step(_): roleDestination(X,Y) & waitingRole
    <- -waitingRole;
    +goingRoleZone;
    +destination(X,Y);
    skip.

+step(_): arrived & goingRoleZone
    <- -goingRoleZone;
    +away;
    adopt(explorer).
+step(_): lastAction(adopt) & lastActionResult(failed_random)
    <- adopt(explorer).

+step(_): away
    <- -away;
    -+destination(1,0);
    skip.
+step(_): not explore
    <- skip.


+step(_): explore & start & firstPoint(X,Y)
    <- -start;
    +goingfirst;
    -+destination(X,Y);
    skip.

+step(_): explore & goingfirst & secondPoint(X,Y)
    <- -goingfirst;
    +goingsecond;
    -+destination(X,Y);
    skip.

+step(_): explore & goingsecond & thirdPoint(X,Y)
    <- -goingsecond;
    +goingthird;
    -+destination(X,Y);
    skip.

+step(_): explore & goingthird & fourthPoint(X,Y)
    <- -goingthird;
    -+destination(X,Y);
    skip.




+destination(X,Y): X<0
    <- -+destination(X+40, Y).
    
+destination(X,Y): X>39
    <- -+destination(X-40, Y).

+destination(X,Y): Y<0
    <- -+destination(X, Y+40).

+destination(X,Y): Y>39
    <- -+destination(X, Y-40).




+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: (thing(1,0,entity,_) | thing(1,0,block,_))
    <- !moveS.
+!moveE: not (thing(1,0,obstacle,_) | thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(e).

+!moveS: thing(0,1,obstacle,_)
    <- clear(0,1).
+!moveS: (thing(0,1,entity,_) | thing(0,1,block,_))
    <- !moveW.
+!moveS: not (thing(0,1,obstacle,_) | thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(s).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: (thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- !moveE.
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: (thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- !moveN.
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).
waitingRole.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.

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

+step(_): goingRoleZone
    <- -goingRoleZone;
    +away;
    adopt(digger).
+step(_): lastAction(adopt) & lastActionResult(failed_random)
    <- adopt(digger).


+step(_): clearing
    <- -clearing;
    clear(0, 3).

+step(_): away & not site(_,_) & not block1(_,_) & not block2(_,_)
    <- -+destination(0,0);
    skip.
+step(_): site(X,Y)
    <- -+destination(X, Y-3);
    +clearing;
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
    <- skip.
+!moveS: not (thing(0,1,obstacle,_) | thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(s).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: (thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- skip.
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: (thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- !moveN.
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).
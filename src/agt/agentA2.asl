start.
locationsFound.

destination(19,19).
firstPoint(19,5).
secondPoint(6,5).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .send("AgentA1", tell, roleDestination(A+X, B+Y));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(_,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
    .send("AgentA1", tell, goalDestination(A+X, B+Y));
    skip.


//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalDestination(_,_) & dispenser(_,_,_) & locationsFound
    <- +endExplore;
    -locationsFound;
    +goingRoleZone;
    -+destination(X,Y);
    skip.


//movement.
+step(_): destination(X,Y) & position(A,B) & X<A
    <- !checkMoveW.

+step(_): destination(X,Y) & position(A,B) & X>A
    <- !checkMoveE.

+step(_): destination(X,Y) & position(A,B) & Y<B
    <- !checkMoveN.

+step(_): destination(X,Y) & position(A,B) & Y>B
    <- !checkMoveS.


//scanning map.
+step(_): arrived & start & firstPoint(X,Y) & not endExplore
    <- -start;
    +goingfirst;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingfirst & secondPoint(X,Y) & not endExplore
    <- -goingfirst;
    +goingsecond;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingsecond & roleDestination(X,Y)
    <- -goingsecond;
    +goingRoleZone;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingsecond & not roleDestination(X,Y)
    <- skip.


//roleZone reached; changing roles.
+step(_): arrived & goingRoleZone
    <- -goingRoleZone;
    +setDispenserDestination;
    adopt(worker).


//setting dispenser as the new destination.
+step(_): role(worker) & dispenser(X,Y,_) & setDispenserDestination
    <- -+destination(X-1,Y);
    -setDispenserDestination;
    +requesting;
    skip.

+step(_): role(worker) & dispenser(X,Y,_) & task(_,_,_,[_,req(-1,1,_)]) & setDispenserDestination
    <- -+destination(X+1,Y);
    -setDispenserDestination;
    +requestingW;
    skip.

+step(_): role(worker) & dispenser(X,Y,_) & task(_,_,_,[_,req(0,2,_)]) & setDispenserDestination
    <- -+destination(X,Y-1);
    -setDispenserDestination;
    +requestingS;
    skip.

+step(_): role(worker) & dispenser(X,Y,_) & task(_,_,_,[_,req(0,-1,_)]) & setDispenserDestination
    <- -+destination(X,Y+1);
    -setDispenserDestination;
    +requestingN;
    skip.


//requesting block from dispenser.
+step(_): arrived & requesting
    <- +attaching;
    +setGoalDestination;
    -requesting;
    request(s).


//attaching block.
+step(_): attaching
    <- +submitting;
    -attaching;
    attach(s).


//setting destination to goalZone.
+step(_): role(worker) & goalDestination(X,Y) & setGoalDestination
    <- -+destination(X,Y);
    -setGoalDestination;
    skip.

//submitting task.
+step(_): arrived & submitting & task(Task,_,_,_)
    <- +setDispenserDestination;
    submit(Task).


//fixing destination coordinates if they are invalid.
+destination(X,Y): X<0
    <- -+destination(X+25, Y).
    
+destination(X,Y): X>24
    <- -+destination(X-25, Y).

+destination(X,Y): Y<0
    <- -+destination(X, Y+25).

+destination(X,Y): Y>24
    <- -+destination(X, Y-25).


//if move is obstructed, clear, otherwise move.
+!checkMoveE: thing(1,0,obstacle,_)
    <- clear(1,0).

+!checkMoveE: not thing(1,0,obstacle,_)
    <- move(e).

+!checkMoveS: thing(0,1,obstacle,_)
    <- clear(0,1).

+!checkMoveS: not thing(0,1,obstacle,_)
    <- move(s).

+!checkMoveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).

+!checkMoveN: not thing(0,-1,obstacle,_)
    <- move(n).

+!checkMoveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).

+!checkMoveW: not thing(-1,0,obstacle,_)
    <- move(w).


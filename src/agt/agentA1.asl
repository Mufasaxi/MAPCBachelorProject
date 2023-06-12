start.

destination(5,5).
firstPoint(5,19).
secondPoint(19,19).
thirdPoint(19,5).
fourthPoint(6,5).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    skip.

+step(_): thing(X,Y,dispenser,Type) & position(A,B) & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
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
+step(_): arrived & start & firstPoint(X,Y)
    <- -start;
    +goindfirst;
    -+destination(X,Y);
    skip.

+step(_): arrived & goindfirst & secondPoint(X,Y)
    <- -goindfirst;
    +goingsecond;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingsecond & thirdPoint(X,Y)
    <- -goingsecond;
    +goingthird;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingthird & fourthPoint(X,Y)
    <- -goingthird;
    +goingfourth;
    -+destination(X,Y);
    skip.

+step(_): arrived & goingfourth & roleDestination(X,Y)
    <- -goingfourth;
    +goingRoleZone;
    -+destination(X,Y);
    skip.


//roleZone reached; changing roles.
+step(_): arrived & goingRoleZone
    <- -goingRoleZone;
    +setDispenserDestination;
    adopt(worker).


//setting dispenser as the new destination.
+step(_): role(worker) & dispenser(X,Y,Type) & task(_,_,_,[req(1,0,ReqType)]) & Type == ReqType & setDispenserDestination
    <- -+destination(X-1,Y);
    -setDispenserDestination;
    +requestingE;
    skip.

+step(_): role(worker) & dispenser(X,Y,Type) & task(_,_,_,[req(-1,0,ReqType)]) & Type == ReqType & setDispenserDestination
    <- -+destination(X+1,Y);
    -setDispenserDestination;
    +requestingW;
    skip.

+step(_): role(worker) & dispenser(X,Y,Type) & task(_,_,_,[req(0,1,ReqType)]) & Type == ReqType & setDispenserDestination
    <- -+destination(X,Y-1);
    -setDispenserDestination;
    +requestingS;
    skip.

+step(_): role(worker) & dispenser(X,Y,Type) & task(_,_,_,[req(0,-1,ReqType)]) & Type == ReqType & setDispenserDestination
    <- -+destination(X,Y+1);
    -setDispenserDestination;
    +requestingN;
    skip.


//requesting block from dispenser.
+step(_): arrived & requestingE
    <- +attachingE;
    +setGoalDestination;
    -requestingE;
    request(e).

+step(_): arrived & requestingW
    <- +attachingW;
    +setGoalDestination;
    -requestingW;
    request(w).

+step(_): arrived & requestingS
    <- +attachingS;
    +setGoalDestination;
    -requestingS;
    request(s).

+step(_): arrived & requestingN
    <- +attachingN;
    +setGoalDestination;
    -requestingN;
    request(n).


//attaching block.
+step(_): attachingE
    <- +submitting;
    -attachingE;
    attach(e).

+step(_): attachingW
    <- +submitting;
    -attachingW;
    attach(w).

+step(_): attachingS
    <- +submitting;
    -attachingS;
    attach(s).

+step(_): attachingN
    <- +submitting;
    -attachingN;
    attach(n).


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


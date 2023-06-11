//setting destination to roleZone.
+step(_): roleZone(X,Y) & position(A,B) & not destination(_,_)
    <- +destination(A+X, B+Y).

//saving dispenser and goalZone coordinates along the way for later.
+step(_): thing(X,Y,dispenser,Type) & position(A,B) & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type).

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y).


//if no roleZone detected, explore to find one.
+step(_): not roleZone(_,_) & not destination(_,_)
    <- !explore.


//deciding which direction to move towards.
+step(_): destination(X,Y) & position(A,B) & X<A
    <- !checkMoveW.

+step(_): destination(X,Y) & position(A,B) & X>A
    <- !checkMoveE.

+step(_): destination(X,Y) & position(A,B) & Y<B
    <- !checkMoveN.

+step(_): destination(X,Y) & position(A,B) & Y>B
    <- !checkMoveS.


//destination reached.
+step(_): destination(X,Y) & position(A,B) & X==A & Y==B & role(default)
    <- +setNewDestination;
    adopt(worker).


//setting dispenser as the new destination.
+step(_): role(worker) & dispenser(X,Y,Type) & task(_,_,_,[req(A,B,ReqType)]) & Type == ReqType & setNewDestination
    <- -+destination(X,Y);
    -setNewDestination.


+step(_): role(worker) & not dispenser(_,_,_)
    <- !explore.


//adjusting to task requirements.
+step(_): destination(X,Y) & position(A,B) & X==A & Y==B & role(worker)
    <- !requestBlock.

+step(_): destination(X,Y) & position(A,B) & X==A & Y==B & role(worker)
    <- !requestBlock.

+step(_): destination(X,Y) & position(A,B) & X==A & Y==B & role(worker)
    <- !requestBlock.

+step(_): destination(X,Y) & position(A,B) & X==A & Y==B & role(worker)
    <- !requestBlock.


+step(_): requestingE
    <- request(e).

+step(_): requestingW
    <- request(w).

+step(_): requestingS
    <- request(s).

+step(_): requestingN
    <- request(n).


//exploring.
+!explore 
    <- .print("exploring");
    .random([n, s, e, w], D);
    move(D).


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


+!requestBlock: task(_,_,_,[req(1,0,_)])
    <- +requestingE;
    !checkMoveW.

+!requestBlock: task(_,_,_,[req(-1,0,_)])
    <- +requestingW;
    !checkMoveE.

+!requestBlock: task(_,_,_,[req(0,1,_)])
    <- +requestingS;
    !checkMoveN.

+!requestBlock: task(_,_,_,[req(0,-1,_)])
    <- +requestingN;
    !checkMoveS.

// !task.
/* +!task: true
    <- !explore;
    !go;
    if (at_zone) {
        adopt(worker);
    } elif (roleZone(X, Y)) {
        -+destination(X, Y);
        !go;
    } else {
        while (not roleZone(X, Y)) {
            !explore;
        }
        ?roleZone(X, Y);
        -+destination(X, Y);
        !go;
    }
    if (dispenser(X, Y)) {
        -+destination(X, Y);
    } else {
        while (not dispenser(X, Y)) {
            !explore;
        }
        ?dispenser(X, Y);
        -+destination(X, Y);
    }
    !go;
    move(n);
    request(s);
    attach(s);
    if (goal(X, Y)) {
        .print("goal");
        -+destination(X, Y);
    } else {
        while (not goal(X, Y)) {
            .print("no goal");
            !explore;
        }
        ?dispenser(X, Y);
        -+destination(X, Y);
    }
    !go_;
    submit(task0).

+!explore: true
    <- .random([n, s, e, w], D);
    move(D);
    if (not destination(_, _)) {
        .print("no destination. explore");
        !explore;
    }.

+thing(X, Y, dispenser, _): true
    <- +dispenser(X, Y).

+roleZone(X, Y): not destination(_, _) & X>0
    <- +destination(X, Y).

+goalZone(X, Y): position(A, B) & not goal(_, _)
    <- +goal(X+A, Y+B).

+!go: true
    <- .print("go");
    while (destination(X, Y) & X>0) {
        move(e);
        -+destination(X-1, Y);
    }

    while (destination(X, Y) & X<0) {
        move(w);
        -+destination(X+1, Y);
    }

    while (destination(X, Y) & Y>0) {
        move(s);
        -+destination(X, Y-1);
    }

    while (destination(X, Y) & Y<0) {
        move(n);
        -+destination(X, Y+1);
    }

    if (roleZone(X, Y) & X==0 & Y==0) {
        .print("arrived");
        +at_zone;
    }.




+!go_: true
    <- .print("gog");
    while (destination(X, Y) & position(A, B) & X<A) {
        move(w);
    }

    while (destination(X, Y) & position(A, B) & X>A) {
        move(e);
    }

    while (destination(X, Y) & position(A, B) & Y<A) {
        move(n);
    }

    while (destination(X, Y) & position(A, B) & Y>A) {
        move(s);
    }. */


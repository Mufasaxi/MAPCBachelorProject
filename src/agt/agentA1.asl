//if no roleZone detected, explore to find one.
+step(_): not roleZone(_,_) 
    <- !explore.

//saving dispenser and goalZone coordinates along the way for later.
+step(_): thing(X,Y,dispenser,Type) & position(A,B)
    <- +dispenser(A+X,B+Y,Type).

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y).

//setting destination and deciding direction to move towards´.
+step(_): roleZone(X,Y) & position(A,B) & not destination(_,_)
    <- +destination(A+X, B+Y).

+step(_): destination(X,Y) & position(A,B) & X<A
    <- !checkMoveW.

+step(_): destination(X,Y) & position(A,B) & X>A
    <- !checkMoveE.

+step(_): destination(X,Y) & position(A,B) & Y<B
    <- !checkMoveN.

+step(_): destination(X,Y) & position(A,B) & Y>B
    <- !checkMoveS.

//roleZone reached; changing role.
+step(_): destination(X,Y) & position(A,B) & X==A & Y==B
    <- adopt(worker);
    skip.

//exploring.
+!explore 
    <- .random([n, s, e, w], D);
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
+!checkMoveE: position(X,Y) & thing(1,0,obstacle,_)
    <- clear(1,0).

+!checkMoveE: position(X,Y) & not thing(1,0,obstacle,_)
    <- move(e).

+!checkMoveS: position(X,Y) & thing(0,1,obstacle,_)
    <- clear(0,1).

+!checkMoveS: position(X,Y) & not thing(0,1,obstacle,_)
    <- move(s).

+!checkMoveN: position(X,Y) & thing(0,-1,obstacle,_)
    <- clear(0,-1).

+!checkMoveN: position(X,Y) & not thing(0,-1,obstacle,_)
    <- move(n).

+!checkMoveW: position(X,Y) & thing(-1,0,obstacle,_)
    <- clear(-1,0).

+!checkMoveW: position(X,Y) & not thing(-1,0,obstacle,_)
    <- move(w).




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


!task.


+!task: true
    <- !explore;
    !go;
    if (at_zone) {
        adopt(worker);
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
        -+destination(X, Y);
    } else {
        while (not goal(X, Y)) {
            !explore;
        }
        ?dispenser(X, Y);
        -+destination(X, Y);
    }
    !go_;
    submit(task0).

/* +!explore: true
    <- .random([n, s, e, w], D);
    move(D);
    if (not destination(_, _)) {
        .print("no destination. explore");
        !explore;
    }. */

+!explore: true
    <- move(s);
    move(s);
    move(s);
    move(s);
    move(e);
    move(e);
    move(e);
    move(e).

+thing(X, Y, dispenser, Det): true
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
    }.


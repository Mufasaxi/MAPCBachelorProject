!task.


+!task: true
    <- !explore;
    !go;
    if (at_zone) {
        adopt(worker);
    } elif (roleZone(X, Y)) {
        -+dest(X, Y);
        !go;
        adopt(worker);
    } else {
        while (not roleZone(_, _)) {
            !explore;
        }
        ?roleZone(X, Y);
        -+dest(X, Y);
    }

    if (dispenser(X, Y)) {
        -+dest(X, Y);
    } else {
        while (not dispenser(X, Y)) {
            !explore;
        }
        ?dispenser(X, Y);
        -+dest(X, Y);
    }
    !go;
    move(n);
    request(s);
    attach(s).

+!explore: true
    <- .random([n, s, e, w], D);
    move(D);
    if (not dest(_, _)) {
        !explore;
    }.

+thing(X, Y, dispenser, Det): true
    <- +dispenser(X, Y).

+roleZone(X, Y): not dest(_, _)
    <- +dest(X, Y).


+!go: true
    <- while (dest(X, Y) & X>0) {
        move(e);
        -+dest(X-1, Y);
    }

    while (dest(X, Y) & X<0) {
        move(w);
        -+dest(X+1, Y);
    }

    while (dest(X, Y) & Y>0) {
        move(s);
        -+dest(X, Y-1);
    }

    while (dest(X, Y) & Y<0) {
        move(n);
        -+dest(X, Y+1);
    }

    if (roleZone(0, 0)) {
        +at_zone;
    }.



//Initial Beliefs

//Initial Goals
!explore.

//Initial Plans
+!explore: not rolePos(_, _)
    <- .random(["n", "s", "e", "w"], D);
    move(D);
    !explore.

+thing(X, Y, Type, Details): Type == "dispenser"
    <- ?position(A, B);
    +dispenser(A+X, B+Y).

+goalZone(X, Y): position(A, B) & X>0 & Y>0 & X<19 & Y<19
    <- +goal(A+X, B+Y).

+roleZone(X, Y): position(A, B) & X>0 & Y>0 & X<19 & Y<19
    <- +rolePos(A+X, B+Y).

+rolePos(X, Y): not roleDest(_, _)
    <- +roleDest(X, Y);
    !change_role.

+!change_role: true
    <- !go;
    adopt("worker").

+!go: roleDest(X, Y) & position(A, B) & X>A
    <- move("e");
    !go.

+!go: roleDest(X, Y) & position(A, B) & X<A
    <- move("w");
    !go.

+!go: roleDest(X, Y) & position(A, B) & Y>B
    <- move("s");
    !go.

+!go: roleDest(X, Y) & position(A, B) & Y<B
    <- move("n");
    !go.

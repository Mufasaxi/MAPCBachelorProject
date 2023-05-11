//Initial Beliefs
direction("n").

//Initial Goals
!explore.


//Initial Plans
+!explore: true
    <- !find_direction;
    ?direction(D);
    move(D);
    !explore.

+!find_direction: true
    <- .shuffle(["n", "s", "e", "w"], Ds);
    .nth(0, Ds, D);
    -+direction(D).



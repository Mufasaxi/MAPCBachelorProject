start.
locationsFound.
tellDispenser.

destination(5,5).
firstPoint(5,19).
secondPoint(19,19).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .send("agentA2", tell, roleDestination(A+X, B+Y));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(_,_,_,[req(_,_,RequestedType),_]) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(_,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & tellDispenser
    <- .send("agentA2", tell, dispenser(A+X,B+Y,Type));
    -tellDispenser;
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
    .send("agentA2", tell, goalDestination(A+X, B+Y));
    skip.


//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalDestination(_,_) & dispenser(_,_,Type) & task(_,_,_,[req(_,_,RequestedType),_]) & Type==RequestedType & locationsFound
    <- +endExplore;
    -locationsFound;
    +goingRoleZone;
    -+destination(X,Y);
    skip.


//changing destination to goalZone to arrange blocks.
+step(_): pos(X,Y)[source(agentA2)] & waiting & task(_,_,_,[req(0,1,_),_])
    <- -+destination(X,Y-3);
    -waiting[source(agentA2)];
    skip.

+step(_): pos(X,Y)[source(agentA2)] & waiting & task(_,_,_,[req(1,1,_),_])
    <- -+destination(X+1,Y);
    -waiting[source(agentA2)];
    skip.

+step(_): pos(X,Y)[source(agentA2)] & waiting & task(_,_,_,[req(-1,1,_),_])
    <- -+destination(X-1,Y);
    -waiting[source(agentA2)];
    skip.

+step(_): pos(X,Y)[source(agentA2)] & waiting & task(_,_,_,[req(0,2,_),_])
    <- -+destination(X+1,Y+2);
    -waiting[source(agentA2)];
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
    <- -+destination(X,Y-1);
    -setDispenserDestination;
    +requesting;
    skip.


//requesting block from dispenser.
+step(_): arrived & requesting
    <- +attaching;
    -requesting;
    request(s).


//attaching block.
+step(_): attaching
    <- +setGoalDestination;
    -attaching;
    attach(s).


/* //meeting to connect blocks.
+step(_): position(X,Y) & meeting & task(_,_,_,[req(A,B,_),_]) & A==0 & B==1
    <- .send("agentA2", tell, position(X-1,Y));
    -meeting;
    +connecting;
    -+destination(X-1,Y);
    skip.

+step(_): position(X,Y) & meeting & task(_,_,_,[req(A,B,_),_]) & not (A==0 & B==1) & waiting & not thing(-1,0,entity,_)
    <- -waiting;
    -+destination(X-1,Y);
    skip.

+position(X,Y)[source(agentA2)]: meeting & task(_,_,_,[req(1,1,_),_])
    <- +connecting;
    -meeting;
    -+destination(X+1,Y);
    skip.
    
+position(X,Y)[source(agentA2)]: meeting & task(_,_,_,[req(-1,1,_),_])
    <- +connecting;
    -meeting;
    -+destination(X-1,Y);
    skip.
    
+position(X,Y)[source(agentA2)]: meeting & task(_,_,_,[req(0,2,_),_])
    <- +rotating;
    -meeting;
    -+destination(X+1,Y+2);
    skip.
    

//connecting blocks.
+step(_): arrived & rotating
    <- +connecting;
    -rotating;
    rotate(cw).

+step(_): arrived & connecting
    <- connect("agentA2", 0, 1). */


//setting destination to goalZone.
+step(_): goalDestination(X,Y) & setGoalDestination & not waiting
    <- -+destination(X,Y);
    +firstToGoal;
    -setGoalDestination;
    skip.


//submitting task.
+step(_): arrived & firstToGoal & task(Task,_,_,_) & position(X,Y)
    <- .send("agentA2", tell, waiting);
    .send("agentA2", tell, pos(X,Y));
    -firstToGoal;
    skip.




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


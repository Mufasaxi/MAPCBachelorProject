start.
locationsFound.
tellDispenser.

destination(19,19).
firstPoint(19,5).
secondPoint(6,5).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .send("agentA1", tell, roleDestination(A+X, B+Y));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(_,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(_,_,_,[req(_,_,RequestedType),_]) & position(A,B) & Type==RequestedType & tellDispenser
    <- .send("agentA1", tell, dispenser(A+X,B+Y,Type));
    -tellDispenser;
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
    .send("agentA1", tell, goalDestination(A+X, B+Y));
    skip.


//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalDestination(_,_) & dispenser(_,_,Type) & task(_,_,_,[_,req(_,_,RequestedType)]) & Type==RequestedType & locationsFound
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

//waiting for other agent to arrive.
+!wait: not waiting
    <- -setGoalDestination;
    !wait;
    skip.

/* //meeting to connect blocks.
+step(_): position(X,Y) & meeting & task(_,_,_,[_,req(A,B,_)]) & A==0 & B==1
    <- .send("agentA1", tell, position(X-1,Y));
    -meeting;
    +goingGoal;
    +connecting;
    -+destination(X-1,Y);
    skip.

+step(_): position(X,Y) & meeting & task(_,_,_,[_,req(A,B,_)]) & not (A==0 & B==1) & waiting
    <- -waiting;
    -+destination(X-1,Y);
    skip.

+position(X,Y)[source(agentA1)]: meeting & task(_,_,_,[_,req(1,1,_)])
    <- +connecting;
    -meeting;
    -+destination(X+1,Y);
    skip.
    
+position(X,Y)[source(agentA1)]: meeting & task(_,_,_,[_,req(-1,1,_)])
    <- +connecting;
    -meeting;
    -+destination(X-1,Y);
    skip.
    
+position(X,Y)[source(agentA1)]: meeting & task(_,_,_,[_,req(0,2,_)])
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
    <- connect("agentA1", 0, 1).

+step(_): goingGoal
    <- +setGoalDestination;
    skip.

+step(_): not goingGoal
    <- +detaching;
    skip.

+step(_): detaching
    <- -detaching;
    +setDispenserDestination;
    detach(s). */


//setting destination to goalZone.
+step(_): goalDestination(X,Y) & setGoalDestination
    <- -+destination(X,Y);
    .send("agentA1", achieve, wait);
    +firstToGoal;
    -setGoalDestination;
    skip.


//submitting task.
+step(_): arrived & firstToGoal & task(Task,_,_,_) & position(X,Y)
    <- .send("agentA1", tell, waiting);
    .send("agentA1", tell, pos(X,Y));
    -firstToGoal;
    skip.


//changing destination to goalZone to arrange blocks.
+step(_): pos(X,Y) & waiting & task(_,_,_,[_,req(0,1,_)])
    <- -+destination(X,Y-3);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[_,req(1,1,_)])
    <- -+destination(X+1,Y);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[_,req(-1,1,_)])
    <- -+destination(X-1,Y);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[_,req(0,2,_)])
    <- -+destination(X+1,Y+2);
    -waiting;
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


//clearing/avoiding obstacles.
+!checkMoveE: thing(1,0,obstacle,_)
    <- clear(1,0).

+!checkMoveE: attached(X,Y) & thing(X+1,Y,obstacle,_)
    <- rotate(cw).

+!checkMoveE: not thing(1,0,obstacle,_)
    <- move(e).

+!checkMoveS: thing(0,1,obstacle,_)
    <- clear(0,1).

+!checkMoveS: attached(X,Y) & thing(X,Y+1,obstacle,_)
    <- rotate(cw).

+!checkMoveS: not thing(0,1,obstacle,_)
    <- move(s).

+!checkMoveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).

+!checkMoveN: attached(X,Y) & thing(X,Y-1,obstacle,_)
    <- rotate(cw).

+!checkMoveN: not thing(0,-1,obstacle,_)
    <- move(n).

+!checkMoveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).

+!checkMoveW: attached(X,Y) & thing(X-1,Y,obstacle,_)
    <-rotate(ccw).

+!checkMoveW: not thing(-1,0,obstacle,_)
    <- move(w).


//fail plans for rotation.
+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([cw]) & attached(0,1)
    <- clear(w).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([ccw]) & attached(0,1)
    <- clear(e).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([cw]) & attached(0,-1)
    <- clear(e).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([ccw]) & attached(0,-1)
    <- clear(w).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([cw]) & attached(1,0)
    <- clear(s).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([ccw]) & attached(1,0)
    <- clear(n).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([cw]) & attached(-1,0)
    <- clear(n).

+step(_): lastAction(rotate) & lastActionResult(failed) & lastActionParam([ccw]) & attached(-1,0)
    <- clear(s).
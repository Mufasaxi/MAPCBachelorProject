start.
locationsFound.
tellDispenser.
choosingTask.

destination(5,5).
firstPoint(5,35).
secondPoint(35,35).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock(X,Y) :- attached(0,1) | attached(1,0) | attached(0,-1) | attached(-1,0).



//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .broadcast(tell, roleDestination(A+X, B+Y));
    skip.

+step(_): task(Task,_,_,[_,_]) & not working(Task) & choosingTask
    <- +working(Task);
    -choosingTask;
    .send("agentA2", tell, working(Task));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(Task,_,_,[req(_,_,RequestedType),_]) & working(Task) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(Task,_,_,[_,req(_,_,RequestedType)]) & working(Task) & position(A,B) & Type==RequestedType & tellDispenser
    <- .send("agentA2", tell, dispenser(A+X,B+Y,Type));
    -tellDispenser;
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
    .broadcast(tell, goalDestination(A+X, B+Y));
    skip.


+step(_): showDispenser(Type) & dispenser(X,Y,Type)
    <- .send("agentA4", tell, dispenser(X,Y,Type));
    -showDispenser(Type);
    skip.


//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalDestination(_,_) & dispenser(_,_,Type) & task(Task,_,_,[req(_,_,RequestedType),_]) & working(Task) & Type==RequestedType & locationsFound
    <- +endExplore;
    -locationsFound;
    +goingRoleZone;
    -+destination(X,Y);
    skip.


//movement.
+step(_): myBlock(_,_) & not attached(1,0) & moving(w) & not readyToConnect
    <- !rotateCW.
+step(_): moving(w)
    <- !moveW.

+step(_): myBlock(_,_) & not attached(-1,0) & moving(e)
    <- !rotateCW.
+step(_): moving(e)
    <- !moveE.

+step(_): myBlock(_,_) & not attached(0,1) & moving(n)
    <- !rotateCW.
+step(_): moving(n)
    <- !moveN.

+step(_): myBlock(_,_) & not attached(0,-1) & moving(s)
    <- !rotateCW.
+step(_): moving(s)
    <- !moveS.


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

/* //waiting for other agent to arrive.
+!wait: not waiting
    <- -setGoalDestination;
    !wait;
    skip. */


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
+step(_): goalDestination(X,Y) & setGoalDestination
    <- -+destination(X,Y);
    -setGoalDestination;
    skip.

+step(_): task(Task,_,_,[req(0,1,_),_]) & working(Task) & not attached(0,1)
    <- !rotateCW.
+step(_): task(Task,_,_,[req(0,1,_),_]) & working(Task) & attached(0,1) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +submitting;
    +connecting;
    +stonks;
    skip.

+step(_): task(Task,_,_,[req(X,_,_),req(0,1,_)]) & working(Task) & (X==-1 | X==1) & not attached(0,1)
    <- !rotateCW.
+step(_): task(Task,_,_,[req(X,_,_),req(0,1,_)]) & working(Task) & (X==-1 | X==1) & attached(0,1) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +connecting;
    +stonks;
    skip.

+step(_): task(Task,_,_,[req(X,_,_),req(0,1,_)]) & working(Task) & X==0 & goalDestination(A,B) & not attached(1,0)
    <- -+destination(A,B+2);
    !rotateCW.
+step(_): task(Task,_,_,[req(X,_,_),req(0,1,_)]) & working(Task) & X==0 & attached(1,0) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +connecting;
    +stonks;
    skip.



/* +step(_): connecting & not connectReady1
    <- .send("agentA2", tell, connectReady1);
    +connectReady1;
    skip. */

/* +step(_): connectReady1 & connectReady2
    <- .wait(2000);
    .print("a1 ready to connnect"). */
+step(_): connecting & /*connectReady2 &*/ attached(0,1)
    <- -connecting;
    +detaching;
    connect("agentA2", 0, 1).
+step(_): connecting & /*connectReady2 &*/ attached(1,0)
    <- -connecting;
    +detaching;
    connect("agentA2", 1, 0).

+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(0,1)
    <- +detaching;
    connect("agentA2", 0, 1).
+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(1,0)
    <- +detaching;
    connect("agentA2", 1,0).

//detaching agent
+step(_): not submitting & detaching & attached(0,1)
    <- -detaching;
    +detached;
    detach(s).
+step(_): not submitting & detaching & attached(1,0)
    <- -detaching;
    +detached;
    detach(e).
+step(_): detached & goalDestination(X,Y)
    <- -+destination(X-1,Y);
    +readyToConnect;
    if(thing(0,1,obstacle,_)) {clear(0,1);}
    else {skip;}.
    

//submitting
+step(_): submitting & task(Task,_,_,_) & working(Task)
    <- +submitted; 
    submit(Task).


+step(_): submitted & dispenser(X,Y,Type) & task(_,_,_,[req(_,_,RequestedType),_]) & Type==RequestedType
    <- -+destination(X,Y);
    -readyToConnect;
    +requesting;
    -submitted;
    skip.

+step(_): submitted & dispenser(X,Y,Type) & task(_,_,_,[_,req(_,_,RequestedType)]) & Type==RequestedType
    <- -+destination(X,Y);
    -readyToConnect;
    +requesting;
    -submitted;
    skip.




/* 
+step(_): submitting & task(Task,_,_,_)
    <- -submitting;
    +submitted;
    submit(Task).
+step(_): not submitting & not submitted & attached(0,1)
    <- detach(s).
+step(_): not submitting & not submitted & attached(1,0)
    <- detach(e). */


/* //submitting task.
+step(_): arrived & firstToGoal & position(X,Y)
    <- .send("agentA2", tell, waiting);
    .send("agentA2", tell, pos(X,Y));
    -firstToGoal;
    skip.


//changing destination to goalZone to arrange blocks.
+step(_): pos(X,Y) & waiting & task(_,_,_,[req(0,1,_),_])
    <- -+destination(X,Y-3);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[req(1,1,_),_])
    <- -+destination(X+1,Y);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[req(-1,1,_),_])
    <- -+destination(X-1,Y);
    -waiting;
    skip.

+step(_): pos(X,Y) & waiting & task(_,_,_,[req(0,2,_),_])
    <- -+destination(X+1,Y+2);
    -waiting;
    skip. */


//fixing destination coordinates if they are invalid.
+destination(X,Y): X<0
    <- -+destination(X+40, Y).
    
+destination(X,Y): X>39
    <- -+destination(X-40, Y).

+destination(X,Y): Y<0
    <- -+destination(X, Y+40).

+destination(X,Y): Y>39
    <- -+destination(X, Y-40).


//clockwise rotation.
+!rotateCW: attached(0,1) & thing(-1,0,obstacle,_)
    <- clear(-1,0).
/* +!rotateCW: attached(0,1) & (thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- !rotateCCW. */
+!rotateCW: attached(0,1) & not thing(-1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(0,-1) & thing(1,0,obstacle,_)
    <- clear(1,0).
/* +!rotateCW: attached(0,-1) & (thing(1,0,entity,_) | thing(1,0,block,_))
    <- !rotateCCW. */
+!rotateCW: attached(0,-1) & not thing(1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(1,0) & thing(0,1,obstacle,_)
    <- clear(0,1).
/* +!rotateCW: attached(1,0) & (thing(0,1,entity,_) | thing(0,1,block,_))
    <- !rotateCCW. */
+!rotateCW: attached(1,0) & not thing(0,1,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(-1,0) & thing(0,-1,obstacle,_)
    <- clear(0,-1).
/* +!rotateCW: attached(-1,0) & (thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- !rotateCCW. */
+!rotateCW: attached(-1,0) & not thing(0,-1,obstacle,_)
    <- rotate(cw).


/* //anti-clockwise rotation
+!rotateCCW: attached(0,1) & thing(1,0,obstacle,_)
    <- clear(1,0).
+!rotateCCW: attached(0,1) & not thing(1,0,obstacle,_)
    <- if(ccw(X) & X<2) {-+ccw(X+1);}
    elif(not ccw(_) | (ccw(X) & X>1)) {-+ccw(0);}
    rotate(ccw).

+!rotateCCW: attached(0,-1) & thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!rotateCCW: attached(0,-1) & not thing(-1,0,obstacle,_)
    <- if(ccw(X) & X<2) {-+ccw(X+1);}
    elif(not ccw(_) | (ccw(X) & X>1)) {-+ccw(0);}
    rotate(ccw).

+!rotateCCW: attached(1,0) & thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!rotateCCW: attached(1,0) & not thing(0,-1,obstacle,_)
    <- if(ccw(X) & X<2) {-+ccw(X+1);}
    elif(not ccw(_) | (ccw(X) & X>1)) {-+ccw(0);}
    rotate(ccw).

+!rotateCCW: attached(-1,0) & thing(0,1,obstacle,_)
    <- clear(0,1).
+!rotateCCW: attached(-1,0) & not thing(0,1,obstacle,_)
    <- if(ccw(X) & X<2) {-+ccw(X+1);}
    elif(not ccw(_) | (ccw(X) & X>1)) {-+ccw(0);}
    rotate(ccw).
 */

//clearing/avoiding obstacles.
+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: (thing(1,0,entity,_) | (thing(1,0,block,_) & not myBlock(1,0)))
    <- !moveS.
+!moveE: not (thing(1,0,obstacle,_) | thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(e).
+!moveE: (thing(1,0,block,_) & myBlock(1,0))
    <- move(e).

+!moveS: thing(0,1,obstacle,_)
    <- clear(0,1).
+!moveS: (thing(0,1,entity,_) | (thing(0,1,block,_) & not myBlock(0,1)))
    <- !moveW.
+!moveS: not (thing(0,1,obstacle,_) | thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(s).
+!moveS: (thing(0,1,block,_) & myBlock(0,1))
    <- move(s).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: (thing(0,-1,entity,_) | (thing(0,-1,block,_) & not myBlock(0,-1)))
    <- !moveE.
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).
+!moveN: (thing(0,-1,block,_) & myBlock(0,-1))
    <- move(n).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: (thing(-1,0,entity,_) | (thing(-1,0,block,_) & not myBlock(-1,0)))
    <- !moveN.
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).
+!moveW: (thing(-1,0,block,_) & myBlock(-1,0))
    <- move(w).


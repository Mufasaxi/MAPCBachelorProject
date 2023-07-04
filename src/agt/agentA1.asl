start.
locationsFound.
tellDispenser.

destination(5,5).
firstPoint(5,19).
secondPoint(19,19).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock(X,Y) :- attached(X,Y) & X<2 & X>-2 & Y<2 & Y>-2.



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


//movement.
+step(_): myBlock(_,_) & not attached(1,0) & moving(w)
    <- if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.
+step(_): moving(w)
    <- !moveW.

+step(_): myBlock(_,_) & not attached(-1,0) & moving(e)
    <- if(ccw(X) & X<2) {!rotateCCW;}
    else {!rotateCW}.
+step(_): moving(e)
    <- !moveE.

+step(_): myBlock(_,_) & not attached(0,1) & moving(n)
    <- if(ccw(X) & X<2) {!rotateCCW;}
    else {!rotateCW}.
+step(_): moving(n)
    <- !moveN.

+step(_): myBlock(_,_) & not attached(0,-1) & moving(s)
    <- if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.
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

+step(_): task(_,_,_,[req(0,1,_),_]) & not attached(0,1)
    <- if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.

+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & X==1 & goalDestination(A,B) & not attached(0,1)
    <- -+destination(A-1,B);
    if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.

+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & X==0 & goalDestination(A,B) & not attached(1,0)
    <- -+destination(A-1,B+2);
    if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.

+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & X==-1 & not attached(0,1)
    <- if(ccw(X) & X<2) {!rotateCCW;} 
    else {!rotateCW}.


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
    <- -+destination(X+25, Y).
    
+destination(X,Y): X>24
    <- -+destination(X-25, Y).

+destination(X,Y): Y<0
    <- -+destination(X, Y+25).

+destination(X,Y): Y>24
    <- -+destination(X, Y-25).


//clockwise rotation.
+!rotateCW: attached(0,1) & thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!rotateCW: attached(0,1) & (thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- !rotateCCW.
+!rotateCW: attached(0,1) & not thing(-1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(0,-1) & thing(1,0,obstacle,_)
    <- clear(1,0).
+!rotateCW: attached(0,-1) & (thing(1,0,entity,_) | thing(1,0,block,_))
    <- !rotateCCW.
+!rotateCW: attached(0,-1) & not thing(1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(1,0) & thing(0,1,obstacle,_)
    <- clear(0,1).
+!rotateCW: attached(1,0) & (thing(0,1,entity,_) | thing(0,1,block,_))
    <- !rotateCCW.
+!rotateCW: attached(1,0) & not thing(0,1,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(-1,0) & thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!rotateCW: attached(-1,0) & (thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- !rotateCCW.
+!rotateCW: attached(-1,0) & not thing(0,-1,obstacle,_)
    <- rotate(cw).


//anti-clockwise rotation
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


//clearing/avoiding obstacles.
+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: (thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(s).
+!moveE: not (thing(1,0,obstacle,_) | (thing(1,0,entity,_) | thing(1,0,block,_)))
    <- move(e).

+!moveS: thing(0,1,obstacle,_)
    <- clear(0,1).
+!moveS: (thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(w).
+!moveS: not (thing(0,1,obstacle,_) | (thing(0,1,entity,_) | thing(0,1,block,_)))
    <- move(s).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: (thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(e).
+!moveN: not (thing(0,-1,obstacle,_) | (thing(0,-1,entity,_) | thing(0,-1,block,_)))
    <- move(n).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: (thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(n).
+!moveW: not (thing(-1,0,obstacle,_) | (thing(-1,0,entity,_) | thing(-1,0,block,_)))
    <- move(w).


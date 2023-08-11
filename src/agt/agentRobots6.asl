start.
locationsFound.
tellDispenser.

destination(35,35).
firstPoint(35,5).
secondPoint(6,5).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock :- attached(0,1) | attached(1,0) | attached(0,-1) | attached(-1,0).
endTask1 :- task(task1,A,_,_) & step(B) & B>A.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .broadcast(tell, roleDestination(A+X, B+Y));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(task1,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(task1,_,_,[req(_,_,RequestedType),_]) & position(A,B) & Type==RequestedType & tellDispenser
    <- .send("agentRobots5", tell, dispenser(A+X,B+Y,Type));
    -tellDispenser;
    skip.

+step(_): goalZone(X,Y) & position(A,B) & not goalDestination(_,_)
    <- +goalDestination(A+X, B+Y);
    .broadcast(tell, goalDestination(A+X, B+Y));
    skip.

+step(_): goalZone(X,Y) & position(A,B) & goalDestination(C,D) & ((X+A-C)>7 | (X+A-C)<(-7)) & not goalArea(_,_)
    <- +goalArea(A+X, B+Y);
    .broadcast(tell, goalArea(A+X, B+Y));
    skip.

+step(_): endTask1
    <- skip.

//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalArea(_,_) & dispenser(_,_,Type) & task(task1,_,_,[_,req(_,_,RequestedType)]) & Type==RequestedType & locationsFound
    <- +endExplore;
    -locationsFound;
    +goingRoleZone;
    -+destination(X,Y);
    skip.


//movement.
+step(_): myBlock & not attached(1,0) & moving(w) & not readyToConnect
    <- !rotateCW.
+step(_): moving(w)
    <- !moveW.

+step(_): myBlock & not attached(-1,0) & moving(e) & not readyToConnect
    <- !rotateCW.
+step(_): moving(e)
    <- !moveE.

+step(_): myBlock & not attached(0,1) & moving(n) & not readyToConnect
    <- !rotateCW.
+step(_): moving(n)
    <- !moveN.

+step(_): myBlock & not attached(0,-1) & moving(s) & not readyToConnect
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
+step(_): lastAction(adopt) & lastActionResult(failed_random)
    <- adopt(worker).


//setting dispenser as the new destination.
+step(_): role(worker) & dispenser(X,Y,Type) & setDispenserDestination
    <- -+destination(X,Y-1);
    -setDispenserDestination;
    +requesting;
    skip.


//requesting block from dispenser.
+step(_): arrived & requesting
    <- +attaching;
    -requesting;
    request(s).
+step(_): lastAction(request) & lastActionResult(failed_random)
    <- request(s).


//attaching block.
+step(_): attaching
    <- +setGoalDestination;
    -attaching;
    attach(s).
+step(_): lastAction(attach) & lastActionResult(failed_random)
    <- attach(s).


//setting destination to goalZone.
+step(_): goalArea(X,Y) & setGoalDestination
    <- -+destination(X+2,Y);
    -setGoalDestination;
    +configuring;
    skip.


//getting into right position/orientation.
+step(_): task(task1,_,_,[_,req(0,1,_)]) & not endTask1 & not attached(0,1) & configuring 
    <- !rotateCW.
+step(_): task(task1,_,_,[_,req(0,1,_)]) & not endTask1 & attached(0,1) & configuring 
    <- +waitingConnect;
    -configuring;
    skip.
+step(_): task(task1,_,_,[_,req(0,1,_)]) & not endTask1 & attached(0,1) & not a5Ready & waitingConnect
    <- skip.
+step(_): task(task1,_,_,[_,req(0,1,_)]) & not endTask1 & attached(0,1) & goalArea(A,B) & a5Ready & waitingConnect
    <- +readyToConnect;
    +connecting;
    +submitting;
    -waitingConnect;
    -+destination(A+1,B);
    if(thing(-1,1,obstacle,_)) {.send("agentRobots3", tell, site(A+1,B+1));}
    skip.

+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & (X==1 | X==-1) & not attached(0,1) & configuring
    <- !rotateCW.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & (X==1 | X==-1) & attached(0,1) & configuring
    <- +waitingConnect;
    -configuring;
    skip.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & (X==1 | X==-1) & attached(0,1) & not a5Ready & waitingConnect
    <- skip.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & (X==1 | X==-1) & attached(0,1) & goalArea(A,B) & a5Ready & waitingConnect
    <- +readyToConnect;
    +connecting;
    -waitingConnect;
    -+destination(A+1,B);
    if(thing(-1,1,obstacle,_)) {.send("agentA3", tell, site(A+1,B+1));}
    skip.

+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & X==0 & goalArea(A,B) & not attached(-1,0) & configuring
    <- -+destination(A+2,B+2);
    !rotateCW.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & X==0 & goalArea(A,B) & attached(-1,0) & configuring
    <- +waitingConnect;
    -configuring;
    skip.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & X==0 & attached(-1,0) & goalArea(A,B) & not a5Ready & waitingConnect
    <- skip.
+step(_): task(task1,_,_,[req(0,1,_),req(X,_,_)]) & not endTask1 & X==0 & attached(-1,0) & goalArea(A,B) & a5Ready & waitingConnect
    <- +readyToConnect;
    +connecting;
    -waitingConnect;
    -+destination(A+1,B+2);
    if(thing(-2,0,obstacle,_)) {.send("agentA3", tell, site(A,B+2));}
    skip.


//connecting.
+step(_): connecting & /*connectReady1 &*/ attached(0,1)
    <- -connecting;
    .send("agentA3", untell, site(_,_));
    +detaching;
    connect("agentRobots5", 0, 1).
+step(_): connecting & /*connectReady1 &*/ attached(-1,0)
    <- -connecting;
    .send("agentA3", untell, site(_,_));
    +detaching;
    connect("agentRobots5", -1, 0).

+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(0,1)
    <- +detaching;
    connect("agentRobots5", 0, 1).
+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(-1,0)
    <- +detaching;
    connect("agentRobots5", -1,0).


//submitting
+step(_): submitting & not goalZone(0,0) & goalArea(X,Y)
    <- -+destination(X,Y);
    +exception;
    skip.
+step(_): submitting & goalZone(0,0) & task(task1,_,_,_) & not endTask1
    <- -submitting;
    -exception;
    +submitted;
    submit(task1).
+step(_): lastAction(submit) & lastActionResult(failed_random) & task(task1,_,_,_) & not endTask1
    <- submit(task1).


//detaching agent
+step(_): not submitting & detaching & attached(0,1)
    <- -detaching;
    +detached;
    detach(s).
+step(_): not submitting & detaching & attached(-1,0)
    <- -detaching;
    +detached;
    detach(w).


//moving on to next task.
+step(_): submitted
    <- +setDispenserDestination;
    -readyToConnect;
    -submitted;
    skip.

+step(_): detached
    <- +setDispenserDestination;
    -readyToConnect;
    -detached;
    skip.


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

/* //anti-clockwise rotation.
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
    rotate(ccw). */


//clearing obstacles/moving.
+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: (thing(1,0,entity,_) | (thing(1,0,block,_) & not myBlock)) & not exception
    <- !moveS.
+!moveE: not (thing(1,0,obstacle,_) | thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(e).
+!moveE: (thing(1,0,block,_) & myBlock)
    <- move(e).

+!moveS: thing(0,1,obstacle,_)
    <- clear(0,1).
+!moveS: (thing(0,1,entity,_) | (thing(0,1,block,_) & not myBlock))
    <- skip.
+!moveS: not (thing(0,1,obstacle,_) | thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(s).
+!moveS: (thing(0,1,block,_) & myBlock)
    <- move(s).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: (thing(0,-1,entity,_) | (thing(0,-1,block,_) & not myBlock))
    <- skip.
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).
+!moveN: (thing(0,-1,block,_) & myBlock)
    <- move(n).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: (thing(-1,0,entity,_) | (thing(-1,0,block,_) & not myBlock)) & not exception
    <- !moveN.
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).
+!moveW: (thing(-1,0,block,_) & myBlock)
    <- move(w).


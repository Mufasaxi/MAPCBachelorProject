start.
locationsFound.
tellDispenser.

destination(5,5).
firstPoint(5,35).
secondPoint(35,35).

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock :- attached(0,1) | attached(1,0) | attached(0,-1) | attached(-1,0).
endTask0 :- task(task0,A,_,_) & step(B) & B>A.


//saving coord to roleZone, goalZone, and dispenser.
+step(_): roleZone(X,Y) & position(A,B) & not roleDestination(_,_)
    <- +roleDestination(A+X, B+Y);
    .broadcast(tell, roleDestination(A+X, B+Y));
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(task0,_,_,[req(_,_,RequestedType),_]) & position(A,B) & Type==RequestedType & not dispenser(_,_,_)
    <- +dispenser(A+X,B+Y,Type);
    skip.

+step(_): thing(X,Y,dispenser,Type) & task(task0,_,_,[_,req(_,_,RequestedType)]) & position(A,B) & Type==RequestedType & tellDispenser
    <- .send("agentRobots2", tell, dispenser(A+X,B+Y,Type));
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

+step(_): endTask0
    <- skip.

//if all locations found, end explore.
+step(_): roleDestination(X,Y) & goalDestination(_,_) & dispenser(_,_,Type) & task(task0,_,_,[req(_,_,RequestedType),_]) & Type==RequestedType & locationsFound
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

+step(_): myBlock & not attached(-1,0) & moving(e)
    <- !rotateCW.
+step(_): moving(e)
    <- !moveE.

+step(_): myBlock & not attached(0,1) & moving(n)
    <- !rotateCW.
+step(_): moving(n)
    <- !moveN.

+step(_): myBlock & not attached(0,-1) & moving(s)
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
+step(_): lastAction(request) & lastActionResult(failed_blocked)
    <- .print("blocked").


//attaching block.
+step(_): attaching
    <- +setGoalDestination;
    -attaching;
    attach(s).
+step(_): lastAction(attach) & lastActionResult(failed_random)
    <- attach(s).

//setting destination to goalZone.
+step(_): goalDestination(X,Y) & setGoalDestination
    <- -+destination(X,Y);
    -setGoalDestination;
    +configuring;
    skip.


//getting into right position/orientation.
+step(_): task(task0,_,_,[req(0,1,_),_]) & not endTask0 & not attached(0,1) & configuring
    <- !rotateCW.
+step(_): task(task0,_,_,[req(0,1,_),_]) & not endTask0 & attached(0,1) & configuring
    <- -configuring;
    +waitingConnect;
    skip.
+step(_): task(task0,_,_,[req(0,1,_),_]) & not endTask0 & attached(0,1) & waitingConnect
    <- .send("agentRobots2", tell, a1Ready);
    +submitting;
    +connecting;
    -waitingConnect;
    skip.

+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & (X==-1 | X==1) & not attached(0,1) & configuring
    <- !rotateCW.
+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & (X==-1 | X==1) & attached(0,1) & configuring
    <- -configuring;
    +waitingConnect;
    skip.
+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & (X==-1 | X==1) & attached(0,1) & waitingConnect
    <- .send("agentRobots2", tell, a1Ready);
    +connecting;
    -waitingConnect;
    skip.

+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & X==0 & goalDestination(A,B) & not attached(1,0) & configuring
    <- -+destination(A,B+2);
    !rotateCW.
+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & X==0 & goalDestination(A,B) & not attached(1,0) & configuring
    <- -configuring;
    +waitingConnect;
    skip.
+step(_): task(task0,_,_,[req(X,_,_),req(0,1,_)]) & not endTask0 & X==0 & attached(1,0) & waitingConnect
    <- .send("agentRobots2", tell, a1Ready);
    +connecting;
    -waitingConnect;
    skip.


//connecting.
+step(_): connecting & attached(0,1)
    <- -connecting;
    +detaching;
    connect("agentRobots2", 0, 1).
+step(_): connecting & attached(1,0)
    <- -connecting;
    +detaching;
    connect("agentRobots2", 1, 0).

+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(0,1)
    <- +detaching;
    connect("agentRobots2", 0, 1).
+step(_): lastAction(connect) & (lastActionResult(failed_partner) | lastActionResult(failed_random)) & attached(1,0)
    <- +detaching;
    connect("agentRobots2", 1,0).


//submitting
+step(_): submitting & task(task0,_,_,_) & not endTask0
    <- -submitting;
    +submitted; 
    submit(task0).
+step(_): lastAction(submit) & lastActionResult(failed_random) & task(task0,_,_,_) & not endTask0
    <- submit(task0).


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
    -detached;
    +nextTask;
    if(thing(0,1,obstacle,_)) {clear(0,1);}
    else {skip;}.
    

//moving on to next Task.
+step(_): submitted
    <- +setDispenserDestination;
    .send("agentRobots2", untell, a1Ready);
    -readyToConnect;
    -submitted;
    skip.

+step(_): nextTask
    <- +setDispenserDestination;
    .send("agentRobots2", untell, a1Ready);
    -readyToConnect;
    -nextTask;
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

+!rotateCW: attached(0,1) & not thing(-1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(0,-1) & thing(1,0,obstacle,_)
    <- clear(1,0).

+!rotateCW: attached(0,-1) & not thing(1,0,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(1,0) & thing(0,1,obstacle,_)
    <- clear(0,1).

+!rotateCW: attached(1,0) & not thing(0,1,obstacle,_)
    <- rotate(cw).

+!rotateCW: attached(-1,0) & thing(0,-1,obstacle,_)
    <- clear(0,-1).

+!rotateCW: attached(-1,0) & not thing(0,-1,obstacle,_)
    <- rotate(cw).



//clearing/avoiding obstacles.
+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: (thing(1,0,entity,_) | (thing(1,0,block,_) & not myBlock))
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
+!moveW: (thing(-1,0,entity,_) | (thing(-1,0,block,_) & not myBlock))
    <- !moveN.
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).
+!moveW: (thing(-1,0,block,_) & myBlock)
    <- move(w).


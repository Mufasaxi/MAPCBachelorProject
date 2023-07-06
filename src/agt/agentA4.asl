choosingTask.
asking.

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock(X,Y) :- attached(0,1) | attached(1,0) | attached(0,-1) | attached(-1,0).



//saving coord to roleZone, goalZone, and dispenser.
+step(_): task(Task,_,_,[_,_,_]) & not working(Task) & choosingTask
    <- +working(Task);
    -choosingTask;
    .send("agentA5", tell, working(Task));
    .send("agentA6", tell, working(Task));
    skip.

+step(_): task(Task,_,_,[req(_,_,Type),_,_]) & working(Task) & asking
    <- .send("agentA1", tell, showDispenser(Type));
    .send("agentA2", tell, showDispenser(Type));
    -asking;
    +waitingRole;
    skip.


+step(_): not roleDestination(X,Y)
    <- skip.
+step(_): roleDestination(X,Y) & waitingRole
    <- -waitingRole;
    +goingRoleZone;
    +destination(X,Y);
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


//roleZone reached; changing roles.
+step(_): arrived & goingRoleZone
    <- -goingRoleZone;
    +setDispenserDestination;
    +away;
    adopt(worker).


//setting dispenser as the new destination.
+step(_): role(worker) & dispenser(X,Y,_) & setDispenserDestination
    <- -+destination(X,Y-1);
    -setDispenserDestination;
    +requesting;
    skip.
+step(_): away
    <- -away;
    -+destination(2,20);
    skip.
+step(_): role(worker) & not dispenser(X,Y,_) & setDispenserDestination
    <- skip.


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

//setting destination to goalZone.
+step(_): goalDestination(X,Y) & setGoalDestination
    <- -+destination(X,Y);
    -setGoalDestination;
    skip.

+step(_): task(_,_,_,[req(0,1,_),_]) & not attached(0,1)
    <- !rotateCW.
+step(_): task(_,_,_,[req(0,1,_),_]) & attached(0,1) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +submitting;
    +connecting;
    +stonks;
    skip.

+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & (X==-1 | X==1) & not attached(0,1)
    <- !rotateCW.
+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & (X==-1 | X==1) & attached(0,1) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +connecting;
    +stonks;
    skip.

+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & X==0 & goalDestination(A,B) & not attached(1,0)
    <- -+destination(A,B+2);
    !rotateCW.
+step(_): task(_,_,_,[req(X,_,_),req(0,1,_)]) & X==0 & attached(1,0) & not stonks
    <- .send("agentA2", tell, a1Ready);
    +connecting;
    +stonks;
    skip.


+step(_): connecting & /*connectReady2 &*/ attached(0,1)
    <- -connecting;
    +detaching;
    connect("agentA2", 0, 1).
+step(_): connecting & /*connectReady2 &*/ attached(1,0)
    <- -connecting;
    +detaching;
    connect("agentA2", 1, 0).

+step(_): lastAction(connect) & lastActionResult(failed_partner) & attached(0,1)
    <- +detaching;
    connect("agentA2", 0, 1).
+step(_): lastAction(connect) & lastActionResult(failed_partner) & attached(1,0)
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
+step(_): submitting & task(Task,_,_,_)
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


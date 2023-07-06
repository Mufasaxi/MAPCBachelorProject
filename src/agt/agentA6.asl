asking.

arrived :- destination(X,Y) & position(A,B) & X==A & Y==B.
moving(w) :- destination(X,Y) & position(A,B) & X<A.
moving(e) :- destination(X,Y) & position(A,B) & X>A.
moving(s) :- destination(X,Y) & position(A,B) & Y>B.
moving(n) :- destination(X,Y) & position(A,B) & Y<B.
myBlock(X,Y) :- attached(0,1) | attached(1,0) | attached(0,-1) | attached(-1,0).


+step(_): task(Task,_,_,[_,_,req(_,_,Type)]) & working(Task) & asking
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

+step(_): myBlock(_,_) & not attached(-1,0) & moving(e) & not readyToConnect
    <- !rotateCW.
+step(_): moving(e)
    <- !moveE.

+step(_): myBlock(_,_) & not attached(0,1) & moving(n) & not readyToConnect
    <- !rotateCW.
+step(_): moving(n)
    <- !moveN.

+step(_): myBlock(_,_) & not attached(0,-1) & moving(s) & not readyToConnect
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
    -+destination(20,2);
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
    <- -+destination(X+2,Y);
    -setGoalDestination;
    skip.


+step(_): task(_,_,_,[_,req(0,1,_)]) & not attached(0,1)
    <- !rotateCW.
+step(_): task(_,_,_,[_,req(0,1,_)]) & attached(0,1) & goalDestination(A,B) & not a1Ready
    <- skip.
+step(_): task(_,_,_,[_,req(0,1,_)]) & attached(0,1) & goalDestination(A,B) & a1Ready & not stonks
    <- +readyToConnect;
    +connecting;
    +submitting;
    +stonks;
    -+destination(A+1,B);
    if(thing(-1,1,obstacle,_)) {.send("agentA3", tell, site(A+1,B+1));}
    skip.

+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & (X==1 | X==-1) & not attached(0,1)
    <- !rotateCW.
+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & (X==1 | X==-1) & attached(0,1) & goalDestination(A,B) & not a1Ready
    <- skip.
+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & (X==1 | X==-1) & attached(0,1) & goalDestination(A,B) & a1Ready & not stonks
    <- +readyToConnect;
    +connecting;
    +stonks;
    -+destination(A+1,B);
    if(thing(-1,1,obstacle,_)) {.send("agentA3", tell, site(A+1,B+1));}
    skip.

+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & X==0 & goalDestination(A,B) & not attached(-1,0)
    <- -+destination(A+2,B+2);
    !rotateCW.
+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & X==0 & attached(-1,0) & goalDestination(A,B) & not a1Ready
    <- skip.
+step(_): task(_,_,_,[req(0,1,_),req(X,_,_)]) & X==0 & attached(-1,0) & goalDestination(A,B) & a1Ready & not stonks
    <- +readyToConnect;
    +connecting;
    +stonks;
    -+destination(A+1,B+2);
    if(thing(-2,0,obstacle,_)) {.send("agentA3", tell, site(A,B+2));}
    skip.


+step(_): connecting & /*connectReady1 &*/ attached(0,1)
    <- -connecting;
    +detaching;
    connect("agentA1", 0, 1).
+step(_): connecting & /*connectReady1 &*/ attached(-1,0)
    <- -connecting;
    +detaching;
    connect("agentA1", -1, 0).

+step(_): lastAction(connect) & lastActionResult(failed_partner) & attached(0,1)
    <- +detaching;
    connect("agentA1", 0, 1).
+step(_): lastAction(connect) & lastActionResult(failed_partner) & attached(-1,0)
    <- +detaching;
    connect("agentA1", -1,0).

//detaching agent
+step(_): not submitting & detaching & attached(0,1)
    <- -detaching;
    detach(s).
+step(_): not submitting & detaching & attached(-1,0)
    <- -detaching;
    detach(w).

//submitting
+step(_): submitting & not goalZone(0,0) & goalDestination(X,Y) & not inGoalZone
    <- -+destination(X,Y);
    +inGoalZone;
    skip.
+step(_): submitting & goalZone(0,0) & task(Task,_,_,_)
    <- -submitting;
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


//clearing obstacles/moving.
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


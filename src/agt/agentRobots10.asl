+step(_): not (thing(0,1,entity,_) | thing(0,-1,entity,_) | thing(1,0,entity,_) | thing(-1,0,entity,_))
    <- skip.

+step(_): thing(0,1,entity,_)
    <- !moveE.

+step(_): thing(0,-1,entity,_)
    <- !moveW.

+step(_): thing(1,0,entity,_)
    <- !moveN.

+step(_): thing(-1,0,entity,_)
    <- !moveS.


+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: not (thing(1,0,obstacle,_) | thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(e).

+!moveW: thing(-1,0,obstacle,_)
    <- clear(-1,0).
+!moveW: not (thing(-1,0,obstacle,_) | thing(-1,0,entity,_) | thing(-1,0,block,_))
    <- move(w).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).

+!moveS: thing(0,1,obstacle,_)
    <- clear(0,1).
+!moveS: not (thing(0,1,obstacle,_) | thing(0,1,entity,_) | thing(0,1,block,_))
    <- move(s).
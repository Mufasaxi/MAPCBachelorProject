+step(_): not (thing(0,1,entity,_) | thing(0,-1,entity,_) | thing(1,0,entity,_) | thing(-1,0,entity,_))
    <- skip.

+step(_): thing(0,1,entity,_) | thing(0,-1,entity,_)
    <- !moveE.

+step(_): thing(1,0,entity,_) | thing(-1,0,entity,_)
    <- !moveN.


+!moveE: thing(1,0,obstacle,_)
    <- clear(1,0).
+!moveE: not (thing(1,0,obstacle,_) | thing(1,0,entity,_) | thing(1,0,block,_))
    <- move(e).

+!moveN: thing(0,-1,obstacle,_)
    <- clear(0,-1).
+!moveN: not (thing(0,-1,obstacle,_) | thing(0,-1,entity,_) | thing(0,-1,block,_))
    <- move(n).
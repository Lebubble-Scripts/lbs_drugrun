--client.lua -- Varaibles for the client-side that will not update at any point. These are just data references. 
carryingAnimDict = 'anim@heists@box_carry@';
carryingAnimName = 'idle';
boxModel = 'hei_prop_heist_box';

--drugrun.lua
boxObj = nil
missionActive = false
truck = nil
pickupBlip = nil
deliveryBlip = nil
hasArrivedAtPickup = false
notifiedDelivery = false
boxesPickedUp = 0
boxesToPickUp = 1
drugType = nil
palletObj = nil
cooldownTime = nil
deliveryStarted = false
deliveryPedsSpawned = false 
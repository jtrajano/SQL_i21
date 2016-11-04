delete    sc 
from    tblICInventoryShipmentCharge sc left join tblICInventoryShipment s
            on sc.intInventoryShipmentId = s.intInventoryShipmentId
where    s.intInventoryShipmentId is null 

delete    rci 
from    tblICInventoryReceiptChargePerItem rci left join tblICInventoryReceiptCharge rc
            on rci.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
where    rc.intInventoryReceiptId is null 
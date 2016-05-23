CREATE VIEW [dbo].[vyuMFGetTraceabilityObject]
	AS 
SELECT intContractHeaderId AS intId ,strContractNumber AS strName, 1 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuCTContractHeaderView
Union
SELECT DISTINCT intShipmentId AS intId , CONVERT(varchar,intTrackingNumber) + ' / ' + strBLNumber AS strName, 2 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuLGShipmentContainerReceiptContracts
Union
SELECT DISTINCT intShipmentBLContainerId AS intId , strContainerNumber AS strName, 3 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuLGShipmentContainerReceiptContracts
Union
SELECT DISTINCT intLotId AS intId , strLotNumber AS strName, 4 AS intObjectTypeId, intItemId,intLocationId 
FROM vyuMFInventoryView
Union
SELECT DISTINCT intParentLotId AS intId , strParentLotNumber AS strName, 5 AS intObjectTypeId,intItemId,0 AS intLocationId 
FROM vyuMFGetParentLot
Union
SELECT DISTINCT intInventoryReceiptId AS intId , strReceiptNumber AS strName, 6 AS intObjectTypeId,0 AS intItemId,0 AS intLocationId 
FROM tblICInventoryReceipt
Union
SELECT DISTINCT intInventoryShipmentId AS intId , strShipmentNumber AS strName, 7 AS intObjectTypeId,0 AS intItemId,0 AS intLocationId 
FROM tblICInventoryShipment

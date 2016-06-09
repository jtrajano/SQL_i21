CREATE VIEW [dbo].[vyuMFGetTraceabilityObject]
	AS 
SELECT intContractHeaderId AS intId ,strContractNumber AS strName, 1 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuCTContractHeaderView Where strContractType='Purchase'
Union
SELECT DISTINCT intLoadId AS intId , strLoadNumber AS strName, 2 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuLGLoadContainerReceiptContracts
Union
SELECT DISTINCT intLoadContainerId AS intId , strContainerNumber AS strName, 3 AS intObjectTypeId, 0 AS intItemId, 0 AS intLocationId 
FROM vyuLGLoadContainerReceiptContracts
Union
SELECT DISTINCT MAX(intLotId) AS intId , strLotNumber AS strName, 4 AS intObjectTypeId, intItemId ,intLocationId 
FROM vyuMFInventoryView Group By strLotNumber,intItemId,intLocationId
Union
SELECT DISTINCT intParentLotId AS intId , strParentLotNumber AS strName, 5 AS intObjectTypeId,intItemId,0 AS intLocationId 
FROM vyuMFGetParentLot
Union
SELECT DISTINCT intInventoryReceiptId AS intId , strReceiptNumber AS strName, 6 AS intObjectTypeId,0 AS intItemId,0 AS intLocationId 
FROM tblICInventoryReceipt
Union
SELECT DISTINCT intInventoryShipmentId AS intId , strShipmentNumber AS strName, 7 AS intObjectTypeId,0 AS intItemId,0 AS intLocationId 
FROM tblICInventoryShipment
Union
SELECT DISTINCT intLotId AS intId , strLotNumber AS strName, -1 AS intObjectTypeId, intItemId ,intLocationId 
FROM vyuMFInventoryView

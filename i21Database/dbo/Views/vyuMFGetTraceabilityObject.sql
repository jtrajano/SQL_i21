CREATE VIEW [dbo].[vyuMFGetTraceabilityObject]
AS
SELECT intContractHeaderId AS intId
	,strContractNumber AS strName
	,1 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM vyuCTContractHeaderView
WHERE strContractType = 'Purchase'

UNION

SELECT DISTINCT intLoadId AS intId
	,strLoadNumber AS strName
	,2 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM vyuLGLoadContainerReceiptContracts

UNION

SELECT DISTINCT intLoadContainerId AS intId
	,strContainerNumber AS strName
	,3 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM vyuLGLoadContainerReceiptContracts

UNION

SELECT DISTINCT MAX(intLotId) AS intId
	,strLotNumber AS strName
	,4 AS intObjectTypeId
	,intItemId
	,intLocationId
FROM vyuMFInventoryView
GROUP BY strLotNumber
	,intItemId
	,intLocationId

UNION

SELECT DISTINCT intParentLotId AS intId
	,strParentLotNumber AS strName
	,5 AS intObjectTypeId
	,intItemId
	,0 AS intLocationId
FROM vyuMFGetParentLot

UNION

SELECT DISTINCT intInventoryReceiptId AS intId
	,strReceiptNumber AS strName
	,6 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM tblICInventoryReceipt

UNION

SELECT DISTINCT intInventoryShipmentId AS intId
	,strShipmentNumber AS strName
	,7 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM tblICInventoryShipment

UNION

SELECT DISTINCT intLoadId AS intId
	,strLoadNumber AS strName
	,8 AS intObjectTypeId
	,0 AS intItemId
	,0 AS intLocationId
FROM tblLGLoad

UNION

SELECT DISTINCT intLotId AS intId
	,strLotNumber AS strName
	,- 1 AS intObjectTypeId
	,intItemId
	,intLocationId
FROM vyuMFInventoryView

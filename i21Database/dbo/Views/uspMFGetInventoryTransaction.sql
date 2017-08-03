CREATE VIEW uspMFGetInventoryTransaction
AS
SELECT dtmBusinessDate AS [Business Date]
	,S.strShiftName AS [Shift Name]
	,US.strUserName AS [User]
	,IA.dtmDate AS [Transaction Date]
	,TT.strName AS [Transaction Type]
	,I1.strItemNo AS [Item No]
	,I1.strDescription AS [Item Desc]
	,L1.strLotNumber AS [Pallet No]
	,SL1.strName AS [Storage Location]
	,IA.dblQty AS [Qty]
	,UM.strUnitMeasure AS [UOM]
	,L2.strLotNumber AS [Related Pallet No]
	,SL2.strName AS [Related Storage Location]
	,I2.strItemNo AS [Old Item No]
	,dtmOldExpiryDate AS [Old Expiry Date]
	,dtmNewExpiryDate AS [New Expiry Date]
	,LS1.strSecondaryStatus AS [Old Pallet Status]
	,LS2.strSecondaryStatus AS [New Pallet Status]
	,E1.strName AS [Old Owner Name]
	,E2.strName AS [New Owner Name]
	,IA.strNote AS [Note]
	,IA.strReason AS [Reason]
FROM tblMFInventoryAdjustment IA
JOIN tblICItem I1 ON I1.intItemId = IA.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = IA.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = IA.intStorageLocationId
JOIN tblICLot L1 ON L1.intLotId = IA.intSourceLotId
LEFT JOIN tblICLot L2 ON L2.intLotId = IA.intDestinationLotId
LEFT JOIN tblICStorageLocation SL2 ON SL2.intStorageLocationId = IA.intDestinationStorageLocationId
JOIN tblICInventoryTransactionType TT ON TT.intTransactionTypeId = IA.intTransactionTypeId
LEFT JOIN tblICItem I2 ON I2.intItemId = IA.intOldItemId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = IA.intOldLotStatusId
LEFT JOIN tblICLotStatus LS2 ON LS2.intLotStatusId = IA.intNewLotStatusId
JOIN tblSMUserSecurity US ON US.intEntityId = IA.intUserId
LEFT JOIN tblMFShift S ON S.intShiftId = IA.intBusinessShiftId
LEFT JOIN tblICItemOwner IO1 ON IO1.intItemOwnerId = IA.intOldItemOwnerId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = IO1.intOwnerId
LEFT JOIN tblICItemOwner IO2 ON IO2.intItemOwnerId = IA.intNewItemOwnerId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = IO2.intOwnerId

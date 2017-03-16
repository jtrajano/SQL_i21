CREATE PROCEDURE uspMFGetDetailedInventory (@strCustomerName NVARCHAR(50))
AS
DECLARE @intOwnerId INT

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

SELECT E.strName AS [Owner]
	,I.strItemNo AS [Item No]
	,I.strDescription AS [Item Desc]
	,PL.strParentLotNumber AS [Lot No]
	,L.dtmDateCreated AS [Created Date]
	,strVendorLotNo AS [Vendor Lot No]
	,L.dtmManufacturedDate AS [Manufactured Date]
	,L.dtmExpiryDate AS [Expiry Date]
	,L.strLotNumber AS [Pallet No]
	,CASE 
		WHEN L.intLotStatusId = 1
			THEN L.dblQty
		ELSE 0
		END AS [Active Qty]
	,CASE 
		WHEN L.intLotStatusId <> 1
			THEN L.dblQty
		ELSE 0
		END AS [Inactive Qty]
	,UM.strUnitMeasure AS UOM
	,SL.strName AS [Storage Location]
	,LS.strSecondaryStatus [Lot Status]
	,L.dblWeight AS Weight
FROM dbo.tblICLot L
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
JOIN dbo.tblEMEntity E ON E.intEntityId = IO1.intOwnerId
WHERE dblQty > 0
	AND IO1.intOwnerId = @intOwnerId

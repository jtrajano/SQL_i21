CREATE PROCEDURE uspMFGetInventory (@strCustomerName NVARCHAR(50))
AS
DECLARE @intOwnerId INT

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

SELECT I.strItemNo
	,I.strDescription
	,PL.strParentLotNumber AS strLotId
	,strVendorLotNo
	,L.dblQty
	,UM.strUnitMeasure
	,SL.strName AS strStorageLocation
	,L.strLotNumber AS strPalletId
	,LS.strSecondaryStatus
FROM dbo.tblICLot L
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
Left JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
WHERE dblQty > 0
	--AND IO1.intOwnerId = @intOwnerId

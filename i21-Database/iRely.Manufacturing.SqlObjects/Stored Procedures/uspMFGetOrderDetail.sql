CREATE PROCEDURE uspMFGetOrderDetail (
	@strPickNo NVARCHAR(50)
	,@strLotNumber NVARCHAR(50)
	,@strDockDoorLocation NVARCHAR(50)
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intStagingLocationId INT
		,@strName NVARCHAR(50)

	SELECT @intStagingLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE strOrderNo = @strPickNo
		AND intLocationId = @intLocationId

	SELECT @strName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStagingLocationId

	SELECT L.intLotId
		,L.strLotNumber
		,PL.strParentLotNumber AS strLotCode
		,I.strItemNo
		,I.strDescription
		,L.dblQty
		,UM.strUnitMeasure
		,@strName AS strFrom
		,@strDockDoorLocation AS strTo
		,'LOT # : ' + L.strLotNumber + '<br />' + 'P-LOT # : ' + PL.strParentLotNumber + '<br />' + 'ITEM : ' + I.strItemNo + '<br />' + I.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 2), L.dblQty)) + ' ' + UM.strUnitMeasure + '<br />' + 'FROM : ' + @strName + '<br />' + 'TO : ' + @strDockDoorLocation AS Task
	FROM tblICLot L
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE L.strLotNumber = @strLotNumber
		AND L.intStorageLocationId = @intStagingLocationId
		AND L.dblQty > 0
END

CREATE PROCEDURE uspMFGetOrderNewLots @intOrderHeaderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemId NVARCHAR(MAX)
	,@intStagingLocationId INT
	,@strLotId NVARCHAR(MAX)

SELECT @strItemId = COALESCE(@strItemId + ',', '') + CONVERT(NVARCHAR, OD.intItemId)
	,@intStagingLocationId = ISNULL(OH.intStagingLocationId, 0)
FROM tblMFOrderDetail OD
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OD.intOrderHeaderId
WHERE OD.intOrderHeaderId = @intOrderHeaderId

SELECT @strLotId = COALESCE(@strLotId + ',', '') + CONVERT(NVARCHAR, OM.intLotId)
FROM tblMFOrderManifest OM
WHERE OM.intOrderHeaderId = @intOrderHeaderId

SELECT L.intLotId
	,L.strLotNumber
	,PL.strParentLotNumber
	,L.strLotAlias
	,LS.strSecondaryStatus AS strLotStatus
	,I.strItemNo
	,I.strDescription
	,L.dblQty AS dblLotQty
	,UM.strUnitMeasure AS strLotQtyUOM
	,@intOrderHeaderId AS intOrderHeaderId
FROM tblICLot L
JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN tblICItem I ON I.intItemId = L.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
WHERE L.dblQty > 0
	AND L.intStorageLocationId = @intStagingLocationId
	AND L.intItemId IN (
		SELECT *
		FROM dbo.fnSplitString(@strItemId, ',')
		)
	AND L.intLotId NOT IN (
		SELECT *
		FROM dbo.fnSplitString(@strLotId, ',')
		)

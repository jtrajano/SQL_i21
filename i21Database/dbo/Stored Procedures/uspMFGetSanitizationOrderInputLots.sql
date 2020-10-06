CREATE PROCEDURE uspMFGetSanitizationOrderInputLots @intLocationId INT
	,@intWorkOrderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intStorageLocationId INT

SELECT @intStorageLocationId = intSanitizationStagingUnitId
FROM dbo.tblSMCompanyLocation
WHERE intCompanyLocationId = @intLocationId

SELECT WL.intWorkOrderInputLotId
	,WL.intWorkOrderId
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,L.dtmDateCreated
	,L.intCreatedEntityId
	,US.strUserName
	,I.strType
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.intUnitPerLayer
	,I.intLayerPerPallet
	,WL.dblQuantity
	,WL.intItemUOMId
	,U.intUnitMeasureId AS intWeightUnitMeasureId
	,U.strUnitMeasure AS strWeightUnitMeasure
	,WL.dblIssuedQuantity
	,WL.intItemIssuedUOMId
	,U1.intUnitMeasureId
	,U1.strUnitMeasure
	,L.dblWeightPerQty
	,LS.intLotStatusId
	,LS.strSecondaryStatus
	,CSL.strSubLocationName
	,SL.intStorageLocationId
	,SL.strName
	,L.strGarden
	,Isnull((
			SELECT Sum(S.dblQty)
			FROM dbo.tblWHSKU S
			JOIN dbo.tblWHContainer C ON S.intContainerId = C.intContainerId
				AND S.intLotId = L.intLotId
				AND C.intStorageLocationId = @intStorageLocationId
			), 0) AS dblStagedQty
	,Isnull((
			SELECT Sum(S.dblQty * S.dblWeightPerUnit)
			FROM dbo.tblWHSKU S
			JOIN dbo.tblWHContainer C ON S.intContainerId = C.intContainerId
				AND S.intLotId = L.intLotId
				AND C.intStorageLocationId = @intStorageLocationId
			), 0) AS dblStagedWeight
	,ISNULL((
			SELECT SUM(PL.dblQuantity)
			FROM dbo.tblMFWorkOrderProducedLot PL
			WHERE PL.intInputLotId = WL.intLotId
				AND PL.intWorkOrderId = WL.intWorkOrderId
			), 0) AS dblProducedWeight
FROM dbo.tblMFWorkOrderInputLot WL
JOIN dbo.tblICLot L ON L.intLotId = WL.intLotId
	AND WL.intWorkOrderId = @intWorkOrderId
JOIN dbo.tblSMUserSecurity US ON US.intEntityId = L.intCreatedEntityId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WL.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WL.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICStorageUnitType SLT ON SLT.intStorageUnitTypeId = SL.intStorageUnitTypeId
ORDER BY L.dtmDateCreated ASC

CREATE PROCEDURE dbo.uspMFGetPreSanitizeLot (@intLocationId INT)
AS
BEGIN
	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,L.dtmDateCreated
		,L.intCreatedUserId
		,US.strUserName
		,I.strType
		,I.intItemId
		,I.strItemNo
		,I.strDescription AS strItemDescription
		,L.dblWeight
		,ISNULL((
				SELECT SUM(dblQty)
				FROM tblICStockReservation LR
				WHERE LR.intLotId = L.intLotId
				), 0) AS dblReservedQty
		,L.dblWeight - ISNULL((
				SELECT SUM(dblQty)
				FROM tblICStockReservation LR
				WHERE LR.intLotId = L.intLotId
				), 0) AS dblAvailableQty
		,L.intWeightUOMId
		,U1.intUnitMeasureId AS intWeightUnitMeasureId
		,U1.strUnitMeasure AS strWeightUnitMeasure
		,LS.intLotStatusId
		,LS.strSecondaryStatus
		,CL.intCompanyLocationId
		,CL.strLocationName
		,CSL.intCompanyLocationSubLocationId
		,CSL.strSubLocationName
		,SL.intStorageLocationId
		,SL.strName
		,L.strGarden 
		,L.dblWeightPerQty
		,L.dblQty
		,IsNull((
				SELECT SUM(WI.dblIssuedQuantity)
				FROM dbo.tblMFWorkOrderInputLot WI
				WHERE WI.intLotId = L.intLotId
				), 0) AS dblInProcessQty
		,L.dblQty - ISNULL((
				SELECT SUM(dblQty) / L.dblWeightPerQty
				FROM tblICStockReservation LR
				WHERE LR.intLotId = L.intLotId
				), 0) AS dblBalance
		,0.0 AS dblSanitizeNow
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,L.intItemUOMId
	FROM dbo.tblICLot L
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = L.intCreatedEntityId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		AND L.dblQty > 0
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = L.intWeightUOMId
	JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	LEFT JOIN dbo.tblICStorageUnitType SLT ON SLT.intStorageUnitTypeId = SL.intStorageUnitTypeId
	WHERE L.intLocationId = @intLocationId
		AND LS.strSecondaryStatus = 'Pre-Sanitized'
	ORDER BY L.dtmDateCreated ASC
END

CREATE PROCEDURE [dbo].uspMFGetStagedLot (@intLocationId INT)
AS
BEGIN
	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,SL.intStorageLocationId
		,SL.strName
		,C.intCategoryId
		,C.strCategoryCode
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,L.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN L.dblQty
			ELSE L.dblWeight
			END AS dblWeight
		,UM1.intUnitMeasureId AS intWeightUnitMeasureId
		,UM1.strUnitMeasure AS strWeightUnitMeasure
		,L.dblWeightPerQty
		,L.dtmDateCreated
		,L.dtmExpiryDate
		,LS.intLotStatusId
		,LS.strSecondaryStatus AS strLotStatus
		,E.intEntityId
		,E.strName strOwnerName
		,OH.intOrderHeaderId
		,OH.strOrderNo AS strReturnNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
		,MIN(W1.dtmPlannedDate) AS dtmRequiredDate
		,CASE 
			WHEN MIN(W1.dtmPlannedDate) IS NOT NULL
				THEN MIN(IsNULL(CASE 
								WHEN L.intWeightUOMId IS NULL
									THEN L.dblQty
								ELSE L.dblWeight
								END, LI1.dblRequiredQty))
			ELSE NULL
			END AS dblRequiredQty
	FROM dbo.tblICLot L
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		AND L.dblQty > 0
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemId = I.intItemId
		AND IO1.ysnDefault = 1
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN dbo.tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
		AND UT.strInternalCode IN (
			'STAGING'
			,'PROD_STAGING'
			)
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT OUTER JOIN dbo.tblEMEntity E ON E.intEntityId = IO1.intOwnerId
	LEFT JOIN dbo.tblMFOrderManifest M ON M.intLotId = L.intLotId
	LEFT JOIN dbo.tblMFOrderDetail LI ON LI.intOrderDetailId = M.intOrderDetailId
	LEFT JOIN dbo.tblMFOrderHeader OH ON OH.intOrderHeaderId = LI.intOrderHeaderId
		AND OH.intOrderDirectionId = 1
		AND OH.intOrderStatusId NOT IN (
			3
			,10
			)
	LEFT JOIN dbo.tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	LEFT JOIN dbo.tblMFOrderManifest M1 ON M1.intLotId = L.intLotId
	LEFT JOIN dbo.tblMFOrderDetail LI1 ON (
			LI1.intOrderDetailId = M1.intOrderDetailId
			OR (
				LI1.intItemId = L.intItemId
				AND LI1.dblQty = 0
				)
			)
	LEFT JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = LI1.intOrderHeaderId
	LEFT JOIN dbo.tblMFWorkOrder W1 ON W1.intWorkOrderId = SW.intWorkOrderId
		AND W1.intStatusId <> 13
	GROUP BY L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,SL.intStorageLocationId
		,SL.strName
		,C.intCategoryId
		,C.strCategoryCode
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,L.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,L.dblWeight
		,UM1.intUnitMeasureId
		,UM1.strUnitMeasure
		,L.dblWeightPerQty
		,L.dtmDateCreated
		,L.strLotAlias
		,L.dtmExpiryDate
		,LS.intLotStatusId
		,LS.strSecondaryStatus
		,E.intEntityId
		,E.strName
		,OH.intOrderHeaderId
		,OH.strOrderNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
		,L.intWeightUOMId
END

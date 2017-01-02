CREATE PROCEDURE [dbo].uspMFGetStagedLot (@intLocationId INT)
AS
BEGIN
	--DECLARE @intStagingLocationId INT
	--	,@intProductionStageLocationId INT
	--	SELECT @intStagingLocationId=strAttributeValue
	--		FROM tblMFManufacturingProcessAttribute
	--		WHERE intLocationId = @intLocationId
	--			AND intAttributeId IN (
	--				SELECT intAttributeId
	--				FROM tblMFAttribute
	--				WHERE strAttributeName IN (
	--						'Staging Location'
	--						)
	--					AND strAttributeValue <> ''
	--				)
	--		SELECT @intProductionStageLocationId=strAttributeValue
	--		FROM tblMFManufacturingProcessAttribute
	--		WHERE intLocationId = @intLocationId
	--			AND intAttributeId IN (
	--				SELECT intAttributeId
	--				FROM tblMFAttribute
	--				WHERE strAttributeName IN (
	--						'Production Staging Location'
	--						)
	--					AND strAttributeValue <> ''
	--				)
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
		,L.dblWeight
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
		,MIN(W.dtmExpectedDate) AS dtmRequiredDate
		,MIN(WC.dblIssuedQuantity) AS dblRequiredQty
	FROM dbo.tblICLot L
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		AND L.dblQty > 0
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemId = I.intItemId
		AND IO1.ysnActive = 1
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	--AND SL.intStorageLocationId IN (@intStagingLocationId 
	--,@intProductionStageLocationId 
	--	)
	JOIN dbo.tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
		AND UT.strInternalCode IN (
			'STAGING'
			,'PROD_STAGING'
			)
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = L.intLotId
	LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WC.intWorkOrderId
		AND W.intStatusId <> 13
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
END

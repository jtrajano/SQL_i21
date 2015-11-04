CREATE PROCEDURE [dbo].uspMFGetStagedContainer (@intLocationId INT)
AS
BEGIN
	DECLARE @strSanitizationStagingLocation NVARCHAR(50)
		,@strBlendProductionStagingLocation NVARCHAR(50)
		,@intStagingLocationId INT
		,@intBlendProductionStagingLocationId INT

	SELECT @strSanitizationStagingLocation = strSanitizationStagingLocation
		,@strBlendProductionStagingLocation = strBlendProductionStagingLocation
	FROM dbo.tblMFCompanyPreference

	SELECT @intStagingLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE intLocationId = @intLocationId
		AND strName = @strSanitizationStagingLocation

	SELECT @intBlendProductionStagingLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE intLocationId = @intLocationId
		AND strName = @strBlendProductionStagingLocation

	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,S.intSKUId
		,C.intContainerId
		,C.strContainerNo
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.strSKUStatus
		,E.strName strOwnerName
		,SL.intStorageLocationId
		,OH.strBOLNo AS strReturnNo
		,OH.intOrderHeaderId
		,OS.strOrderStatus
		,MIN(W.dtmExpectedDate) [dtmRequiredDate]
		,MIN(WC.dblIssuedQuantity) AS [dblRequiredQty]
	FROM dbo.tblWHSKU S
	JOIN dbo.tblWHSKUStatus SS ON SS.intSKUStatusId = S.intSKUStatusId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intUOMId
	JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
	JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = C.intStorageLocationId
		AND SL.intStorageLocationId IN (
			@intStagingLocationId
			,@intBlendProductionStagingLocationId
			)
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = S.intLotId
	LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WC.intWorkOrderId
	LEFT OUTER JOIN dbo.tblEntity E ON E.intEntityId = S.intOwnerId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	LEFT JOIN dbo.tblWHContainerInboundOrder CI ON CI.intContainerId = C.intContainerId
	LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = CI.intOrderHeaderId
	LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	GROUP BY L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,S.intSKUId
		,C.intContainerId
		,C.strContainerNo
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.strSKUStatus
		,E.strName
		,SL.intStorageLocationId
		,OH.strBOLNo
		,OH.intOrderHeaderId
		,OS.strOrderStatus
	
	UNION
	
	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,S.intSKUId
		,C.intContainerId
		,C.strContainerNo
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.strSKUStatus
		,E.strName strOwnerName
		,SL.intStorageLocationId
		,OH.strBOLNo AS strReturnNo
		,OH.intOrderHeaderId
		,OS.strOrderStatus AS strReturnStatus
		,MIN(W.dtmExpectedDate) [dtmRequiredDate]
		,MIN(WC.dblIssuedQuantity) AS [dblRequiredQty]
	FROM dbo.tblWHSKU S
	JOIN dbo.tblWHSKUStatus SS ON SS.intSKUStatusId = S.intSKUStatusId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intUOMId
	JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
	JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = C.intStorageLocationId
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = S.intLotId
	LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WC.intWorkOrderId
	LEFT OUTER JOIN dbo.tblEntity E ON E.intEntityId = S.intOwnerId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	JOIN dbo.tblWHContainerInboundOrder CI ON CI.intContainerId = C.intContainerId
	JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = CI.intOrderHeaderId
	JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	GROUP BY L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,S.intSKUId
		,C.intContainerId
		,C.strContainerNo
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.strSKUStatus
		,E.strName
		,SL.intStorageLocationId
		,OH.strBOLNo
		,OH.intOrderHeaderId
		,strOrderStatus
END

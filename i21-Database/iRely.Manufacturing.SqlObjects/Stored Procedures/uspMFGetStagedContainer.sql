CREATE PROCEDURE [dbo].uspMFGetStagedContainer (@intLocationId INT)
AS
BEGIN
	DECLARE
		--@strSanitizationStagingLocation NVARCHAR(50)
		--,@strBlendProductionStagingLocation NVARCHAR(50)
		--,@intStagingLocationId INT
		--,@intBlendProductionStagingLocationId INT
		--,
		@intSanitizationStagingUnitId INT
		,@intBlendProductionStagingUnitId INT

	--SELECT @strSanitizationStagingLocation = strSanitizationStagingLocation
	--	,@strBlendProductionStagingLocation = strBlendProductionStagingLocation
	--FROM dbo.tblMFCompanyPreference
	SELECT @intSanitizationStagingUnitId = intSanitizationStagingUnitId
		,@intBlendProductionStagingUnitId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	--SELECT @intStagingLocationId = intStorageLocationId
	--FROM tblICStorageLocation
	--WHERE intLocationId = @intLocationId
	--	AND strName = @strSanitizationStagingLocation
	--SELECT @intBlendProductionStagingLocationId = intStorageLocationId
	--FROM tblICStorageLocation
	--WHERE intLocationId = @intLocationId
	--	AND strName = @strBlendProductionStagingLocation
	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,C.intContainerId
		,C.strContainerNo
		,SL.intStorageLocationId
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,(
			CASE 
				WHEN S.dtmProductionDate = '1990-01-01 00:00:00.000'
					THEN S.dtmReceiveDate 
				ELSE S.dtmProductionDate
				END
			) AS dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.intSKUStatusId
		,SS.strSKUStatus
		,E.intEntityId
		,E.strName strOwnerName
		,OH.intOrderHeaderId
		,OH.strBOLNo AS strReturnNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
		,MIN(W.dtmExpectedDate) AS dtmRequiredDate
		,MIN(WC.dblIssuedQuantity) AS dblRequiredQty
	FROM dbo.tblWHSKU S
	JOIN dbo.tblWHSKUStatus SS ON SS.intSKUStatusId = S.intSKUStatusId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intUOMId
	JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
	JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = C.intStorageLocationId
		AND SL.intStorageLocationId IN (
			@intSanitizationStagingUnitId
			,@intBlendProductionStagingUnitId
			)
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = S.intLotId
	LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WC.intWorkOrderId
	LEFT OUTER JOIN dbo.tblEMEntity E ON E.intEntityId = S.intOwnerId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	LEFT JOIN dbo.tblWHContainerInboundOrder CI ON CI.intContainerId = C.intContainerId
	LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = CI.intOrderHeaderId
		AND OH.intOrderStatusId NOT IN (
			3
			,10
			)
	LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	GROUP BY L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,C.intContainerId
		,C.strContainerNo
		,SL.intStorageLocationId
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.dtmReceiveDate 
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.intSKUStatusId
		,SS.strSKUStatus
		,E.intEntityId
		,E.strName
		,OH.intOrderHeaderId
		,OH.strBOLNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
	
	UNION
	
	SELECT L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,C.intContainerId
		,C.strContainerNo
		,SL.intStorageLocationId
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,(
			CASE 
				WHEN S.dtmProductionDate = '1990-01-01 00:00:00.000'
					THEN S.dtmReceiveDate 
				ELSE S.dtmProductionDate
				END
			) AS dtmProductionDate
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.intSKUStatusId
		,SS.strSKUStatus
		,E.intEntityId
		,E.strName strOwnerName
		,OH.intOrderHeaderId
		,OH.strBOLNo AS strReturnNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
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
	LEFT OUTER JOIN dbo.tblEMEntity E ON E.intEntityId = S.intOwnerId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	JOIN dbo.tblWHContainerInboundOrder CI ON CI.intContainerId = C.intContainerId
	JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = CI.intOrderHeaderId
		AND OH.intOrderStatusId NOT IN (
			3
			,10
			)
	JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	GROUP BY L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,C.intContainerId
		,C.strContainerNo
		,SL.intStorageLocationId
		,SL.strName
		,S.intSKUId
		,S.strSKUNo
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,S.dblQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,S.dtmProductionDate
		,S.dtmReceiveDate 
		,S.strLotCode
		,S.dtmExpiryDate
		,SS.intSKUStatusId
		,SS.strSKUStatus
		,E.intEntityId
		,E.strName
		,OH.intOrderHeaderId
		,OH.strBOLNo
		,OS.intOrderStatusId
		,OS.strOrderStatus
END

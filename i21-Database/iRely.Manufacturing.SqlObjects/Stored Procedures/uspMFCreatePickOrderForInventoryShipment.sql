CREATE PROCEDURE uspMFCreatePickOrderForInventoryShipment @intInventoryShipmentId INT
	,@intUserId INT
	,@intOrderHeaderId INT OUTPUT
AS
BEGIN TRY
	DECLARE @tblMFOrderHeader TABLE (intOrderHeaderId INT)
	DECLARE @strErrMsg NVARCHAR(MAX)
		,@intInventoryShipmentItemId INT
		,@strInventoryShipmentNo NVARCHAR(100)
		,@intShipFromLocationId INT
		,@strOrderNo NVARCHAR(100)
		,@OrderHeaderInformation AS OrderHeaderInformation
		,@OrderDetailInformation AS OrderDetailInformation
		,@intStageLocationId INT
		,@dtmCurrentDate DATETIME
		,@strUserName NVARCHAR(100)
		,@strReferenceNo NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@intItemId INT
		,@ysnGenerateTaskOnCreatePickOrder BIT
		,@intDockDoorId INT

	SELECT @strInventoryShipmentNo = strShipmentNumber
		,@intShipFromLocationId = intShipFromLocationId
		,@dtmCurrentDate = GETDATE()
		,@strReferenceNo = CASE 
			WHEN strReferenceNumber <> ''
				THEN 'Ref. # ' + strReferenceNumber
			ELSE ''
			END
	FROM tblICInventoryShipment
	WHERE intInventoryShipmentId = @intInventoryShipmentId

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @intUserId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
		,@intItemId = NULL
		,@intManufacturingId = NULL
		,@intSubLocationId = NULL
		,@intLocationId = @intShipFromLocationId
		,@intOrderTypeId = 6
		,@intBlendRequirementId = NULL
		,@intPatternCode = 75
		,@ysnProposed = 0
		,@strPatternString = @strOrderNo OUTPUT

	SELECT @intStageLocationId = intStorageLocationId
		,@intDockDoorId = intDockDoorId
	FROM tblICInventoryShipmentItem
	WHERE intInventoryShipmentId = @intInventoryShipmentId
		AND intStorageLocationId IS NOT NULL
		OR intDockDoorId IS NOT NULL

	IF @intStageLocationId IS NULL
	BEGIN
		SELECT @intStageLocationId = intDefaultBlendProductionLocationId--intDefaultOutboundStagingUnitId
		FROM tblSMCompanyLocation 
		Where intCompanyLocationId =@intShipFromLocationId
	END

	IF @intDockDoorId IS NULL
	BEGIN
		SELECT @intDockDoorId = intDefaultInboundDockDoorUnitId--intDefaultOutboundDockDoorUnitId
		FROM tblSMCompanyLocation
		Where intCompanyLocationId =@intShipFromLocationId
	END

	IF @intStageLocationId IS NULL
	BEGIN
		SELECT @intStageLocationId = intDefaultShipmentStagingLocation
		FROM tblMFCompanyPreference
	END

	IF @intDockDoorId IS NULL
	BEGIN
		SELECT @intDockDoorId = intDefaultShipmentDockDoorLocation
		FROM tblMFCompanyPreference
	END

	IF EXISTS (
			SELECT 1
			FROM tblMFOrderHeader
			WHERE strReferenceNo = @strInventoryShipmentNo
			)
	BEGIN
		SET @strErrMsg = 'Pick order has already been created for inventory shipment ' + @strInventoryShipmentNo + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	INSERT INTO @OrderHeaderInformation (
		intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,strLastUpdateBy
		,intLocationId
		,intDockDoorId
		)
	SELECT 1
		,5
		,2
		,@strOrderNo
		,@strInventoryShipmentNo
		,@intStageLocationId
		,@strReferenceNo
		,@dtmCurrentDate
		,@strUserName
		,@intShipFromLocationId
		,@intDockDoorId

	INSERT INTO @tblMFOrderHeader
	EXEC dbo.uspMFCreateStagingOrder @OrderHeaderInformation = @OrderHeaderInformation

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblMFOrderHeader

	INSERT INTO @OrderDetailInformation (
		intOrderHeaderId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dblWeightPerUnit
		,intUnitsPerLayer
		,intLayersPerPallet
		,intPreferenceId
		,intLineNo
		,intSanitizationOrderDetailsId
		,strLineItemNote
		,intStagingLocationId
		,intOwnershipType
		)
	SELECT @intOrderHeaderId
		,SHI.intItemId
		,SHI.dblQuantity
		,SHI.intItemUOMId
		,dbo.fnMFConvertQuantityToTargetItemUOM(SHI.intItemUOMId, IU.intItemUOMId, SHI.dblQuantity)
		,IU.intItemUOMId
		,dbo.fnMFConvertQuantityToTargetItemUOM(SHI.intItemUOMId, IU.intItemUOMId, 1) --1/(Case When IU.dblUnitQty=0 then 1 else IU.dblUnitQty End)
		,I.intUnitPerLayer
		,I.intLayerPerPallet
		,(
			SELECT TOP 1 intPickListPreferenceId
			FROM tblMFPickListPreference
			)
		,Row_Number() OVER (
			ORDER BY SHI.intInventoryShipmentItemId
			)
		,NULL
		,''
		,SHI.intStorageLocationId
		,SHI.intOwnershipType
	FROM dbo.tblICInventoryShipment ISH
	JOIN tblICInventoryShipmentItem SHI ON SHI.intInventoryShipmentId = ISH.intInventoryShipmentId
	JOIN dbo.tblICItem I ON I.intItemId = SHI.intItemId
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.intUnitMeasureId = I.intWeightUOMId
	WHERE ISH.intInventoryShipmentId = @intInventoryShipmentId

	IF EXISTS (
			SELECT *
			FROM @OrderDetailInformation
			WHERE intWeightUOMId IS NULL
			)
	BEGIN
		SELECT @intItemId = intItemId
		FROM @OrderDetailInformation
		WHERE intWeightUOMId IS NULL

		SELECT @strItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @strErrMsg = 'Weight is not configured for the item ' + @strItemNo + ' in the item configuration'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM @OrderDetailInformation
			)
	BEGIN
		RAISERROR (
				'There is no item to create a pick list for the selected inventory shipment.'
				,16
				,1
				)

		RETURN
	END

	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation = @OrderDetailInformation

	DELETE
	FROM tblMFOrderHeader
	WHERE intOrderTypeId = 5
		AND strReferenceNo NOT IN (
			SELECT S.strShipmentNumber
			FROM tblICInventoryShipment S
			)

	DELETE T
	FROM tblMFTask T
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
		AND OH.intOrderTypeId = 5
		AND T.intTaskStateId <> 4
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
		AND S.ysnPosted = 1

	DELETE T
	FROM tblMFTask T
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
		AND OH.intOrderTypeId = 1
		AND T.intTaskStateId <> 4
	JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = T.intOrderHeaderId
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
		AND W.intStatusId = 13

	DELETE
	FROM tblICStockReservation
	WHERE intInventoryTransactionType = 34
		AND ysnPosted = 0
		AND NOT EXISTS (
			SELECT *
			FROM tblMFTask
			WHERE intLotId = tblICStockReservation.intLotId
				AND intOrderHeaderId = tblICStockReservation.intTransactionId
			)

	SELECT @ysnGenerateTaskOnCreatePickOrder = ysnGenerateTaskOnCreatePickOrder
	FROM tblMFCompanyPreference

	IF IsNULL(@ysnGenerateTaskOnCreatePickOrder, 0) = 1
	BEGIN
		EXEC uspMFGenerateTask @intOrderHeaderId = @intOrderHeaderId
			,@intEntityUserSecurityId = @intUserId
			,@ysnAllTasksNotGenerated = 0
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

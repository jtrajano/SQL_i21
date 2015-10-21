CREATE PROCEDURE [dbo].uspMFCreateWorkOrder (
	@strXML NVARCHAR(MAX)
	,@intWorkOrderId INT OUTPUT
	,@strWorkOrderNo NVARCHAR(50) OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblQuantity NUMERIC(18, 6)
		,@intUserId INT
		,@intItemId INT
		,@strLotNumber NVARCHAR(50)
		,@strVendorLotNo NVARCHAR(50)
		,@intItemUOMId INT
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intManufacturingProcessId INT
		,@intStorageLocationId INT
		,@intExecutionOrder INT
		,@dtmCurrentDate DATETIME
		,@intSubLocationId INT
		,@intProductionTypeId INT
		,@strSpecialInstruction NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@intParentWorkOrderId INT
		,@intSalesRepresentativeId INT
		,@intCustomerId INT
		,@strSalesOrderNo NVARCHAR(50)
		,@intSupervisorId INT
		,@intStatusId INT
		,@strCurrentDate NVARCHAR(50)
		,@intWorkOrderConsumedLotId INT
		,@intWorkOrderInputLotId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strWorkOrderNo = strWorkOrderNo
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@intUserId = intUserId
		,@strLotNumber = strLotNumber
		,@strVendorLotNo = strVendorLotNo
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intProductionTypeId = intProductionTypeId
		,@strSpecialInstruction = strSpecialInstruction
		,@strComment = strComment
		,@intParentWorkOrderId = intParentWorkOrderId
		,@intSalesRepresentativeId = intSalesRepresentativeId
		,@intCustomerId = intCustomerId
		,@strSalesOrderNo = strSalesOrderNo
		,@intSupervisorId = intSupervisorId
		,@intStatusId = intStatusId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strWorkOrderNo NVARCHAR(50)
			,intManufacturingProcessId INT
			,intManufacturingCellId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			,strLotNumber NVARCHAR(50)
			,strVendorLotNo NVARCHAR(50)
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intProductionTypeId INT
			,strSpecialInstruction NVARCHAR(MAX)
			,strComment NVARCHAR(MAX)
			,intParentWorkOrderId INT
			,intSalesRepresentativeId INT
			,intCustomerId INT
			,strSalesOrderNo NVARCHAR(50)
			,intSupervisorId INT
			,intStatusId INT
			)

	BEGIN TRANSACTION

	SELECT @dtmCurrentDate = GetDate()

	IF @strWorkOrderNo IS NULL
		OR @strWorkOrderNo = ''
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 70
			,@strWorkOrderNo OUTPUT
	END

	SELECT @intExecutionOrder = Max(intExecutionOrder) + 1
	FROM dbo.tblMFWorkOrder
	WHERE dtmPlannedDate = @dtmPlannedDate
		AND intManufacturingCellId = @intManufacturingCellId

	INSERT INTO dbo.tblMFWorkOrder (
		strWorkOrderNo
		,intManufacturingProcessId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,intStatusId
		,intManufacturingCellId
		,intStorageLocationId
		,intLocationId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,strLotNumber
		,strVendorLotNo
		,dtmPlannedDate
		,intPlannedShiftId
		,dtmExpectedDate
		,intExecutionOrder
		,dtmActualProductionStartDate
		,intProductionTypeId
		,strSpecialInstruction
		,strComment
		,intParentWorkOrderId
		,intSalesRepresentativeId
		,intSupervisorId
		,dtmOrderDate
		)
	SELECT @strWorkOrderNo
		,@intManufacturingProcessId
		,@intItemId
		,@dblQuantity
		,@intItemUOMId
		,@intStatusId
		,@intManufacturingCellId
		,@intStorageLocationId
		,@intLocationId
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,@strLotNumber
		,@strVendorLotNo
		,@dtmPlannedDate
		,@intPlannedShiftId
		,@dtmPlannedDate
		,ISNULL(@intExecutionOrder, 1)
		,@dtmCurrentDate
		,@intProductionTypeId
		,@strSpecialInstruction
		,@strComment
		,@intParentWorkOrderId
		,@intSalesRepresentativeId
		,@intSupervisorId
		,@dtmPlannedDate

	SET @intWorkOrderId = SCOPE_IDENTITY()

	INSERT INTO tblMFWorkOrderInputLot (
		intWorkOrderId
		,intLotId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,intSequenceNo
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,intLotId
		,intItemId
		,dblWeight
		,intWeightUOMId
		,dblQty
		,intItemUOMId
		,NULL
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			) x

	SELECT @intWorkOrderInputLotId = SCOPE_IDENTITY()

	INSERT INTO tblMFWorkOrderConsumedLot (
		intWorkOrderId
		,intLotId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,intSequenceNo
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,intLotId
		,intItemId
		,dblWeight
		,intWeightUOMId
		,dblQty
		,intItemUOMId
		,NULL
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			) x

	SELECT @intWorkOrderConsumedLotId = SCOPE_IDENTITY()

	--Create Reservation
	EXEC [uspMFCreateLotReservation] @intWorkOrderId = @intWorkOrderId
		,@ysnReservationByParentLot = 0

	DECLARE @intOwnerId INT
		,@strSanitizationStagingLocation NVARCHAR(50)
		,@intOrderTermsId INT
		,@strUserName NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@intEntityId INT
		,@intOrderHeaderId INT

	SELECT @intOwnerId = IO.intOwnerId
	FROM dbo.tblICItemOwner IO
	WHERE intItemId IN (
			SELECT intItemId
			FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (intItemId INT) x
			)

	SELECT @strSanitizationStagingLocation = strSanitizationStagingLocation
	FROM dbo.tblMFCompanyPreference

	SELECT @intStorageLocationId = intStorageLocationId
	FROM dbo.tblICStorageLocation
	WHERE strName = @strSanitizationStagingLocation
		AND intLocationId = @intLocationId

	SELECT @intEntityId = E.intEntityId
	FROM dbo.tblEntity E
	JOIN dbo.tblEntityType ET ON E.intEntityId = ET.intEntityId
	WHERE ET.strType = 'Warehouse'
		AND E.strName = 'Production'

	SELECT @intOrderTermsId = intOrderTermsId
	FROM tblWHOrderTerms
	WHERE ysnDefault = 1

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @intUserId

	EXEC dbo.uspSMGetStartingNumber 75
		,@strBOLNo OUTPUT

	DECLARE @tblWHOrderHeader TABLE (intOrderHeaderId INT)

	SELECT @strXML = '<root>'

	SELECT @strXML += '<intOrderStatusId>1</intOrderStatusId>'

	SELECT @strXML += '<intOrderTypeId>8</intOrderTypeId>'

	SELECT @strXML += '<intOrderDirectionId>2</intOrderDirectionId>'

	SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

	SELECT @strXML += '<strReferenceNo>' + @strWorkOrderNo + '</strReferenceNo>'

	SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCurrentDate) + '</dtmRAD>'

	SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

	SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intStorageLocationId) + '</intStagingLocationId>'

	SELECT @strXML += '<intFreightTermId>' + LTRIM(@intOrderTermsId) + '</intFreightTermId>'

	SELECT @strXML += '<intShipFromAddressId>' + LTRIM(@intLocationId) + '</intShipFromAddressId>'

	SELECT @strXML += '<intShipToAddressId>' + LTRIM(@intEntityId) + '</intShipToAddressId>'

	SELECT @strXML += '<strLastUpdateBy>' + LTRIM(@strUserName) + ' </strLastUpdateBy>'

	SELECT @strXML += '</root>'

	INSERT INTO @tblWHOrderHeader
	EXEC dbo.uspWHOutboundOrderCreate @strXML = @strXML

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblWHOrderHeader

	UPDATE dbo.tblMFWorkOrder
	SET intOrderHeaderId = @intOrderHeaderId
		,strBOLNo = @strBOLNo
	WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO tblWHOrderLineItem (
		intOrderHeaderId
		,intItemId
		,dblQty
		,intReceiptQtyUOMId
		,intLastUpdateId
		,dtmLastUpdateOn
		,intPreferenceId
		,dblRequiredQty
		,intUnitsPerLayer
		,intLayersPerPallet
		,intLineNo
		,dblPhysicalCount
		,intPhysicalCountUOMId
		,dblWeightPerUnit
		,intWeightPerUnitUOMId
		,dtmProductionDate
		,strLotAlias
		,intSanitizationOrderDetailsId
		,intLotId
		)
	SELECT @intOrderHeaderId
		,@intItemId
		,CL.dblIssuedQuantity
		,CL.intItemIssuedUOMId
		,CL.intCreatedUserId
		,CL.dtmCreated
		,(
			SELECT TOP 1 intPreferenceId
			FROM dbo.tblWHPickPreference
			WHERE ysnDefault = 1
			)
		,CL.dblIssuedQuantity
		,ISNULL((
				SELECT MAX(intUnitPerLayer)
				FROM tblWHSKU S
				WHERE S.intLotId = CL.intLotId
				), I.intUnitPerLayer)
		,ISNULL((
				SELECT MAX(intLayerPerPallet)
				FROM tblWHSKU S1
				WHERE S1.intLotId = CL.intLotId
				), I.intLayerPerPallet)
		,intSequenceNo
		,CL.dblIssuedQuantity
		,CL.intItemIssuedUOMId
		,CL.dblQuantity / CL.dblIssuedQuantity
		,IU.intUnitMeasureId
		,@dtmCurrentDate
		,L.strLotAlias
		,CL.intWorkOrderInputLotId
		,L.intLotId
	FROM dbo.tblMFWorkOrderInputLot CL
	JOIN dbo.tblICLot L ON L.intLotId = CL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = CL.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = CL.intItemUOMId
	WHERE CL.intWorkOrderInputLotId = @intWorkOrderInputLotId

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO



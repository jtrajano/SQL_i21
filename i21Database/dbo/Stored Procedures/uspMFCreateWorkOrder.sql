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
		,@intCategoryId INT
		,@ysnKittingEnabled BIT
		,@intAttributeTypeId INT
		,@intBlendRequirementId INT
		,@intUnitMeasureId INT
		,@strDemandNo NVARCHAR(50)
		,@strReferenceNo NVARCHAR(50)
		,@strLotAlias NVARCHAR(50)
		,@strVesselNo NVARCHAR(50)
		,@dblActualQuantity NUMERIC(18, 6)
		,@dblNoOfUnits NUMERIC(18, 6)
		,@intNoOfUnitsItemUOMId INT

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
		,@strReferenceNo = strReferenceNo
		,@strLotAlias = strLotAlias
		,@strVesselNo = strVesselNo
		,@dblActualQuantity = dblActualQuantity
		,@dblNoOfUnits = dblNoOfUnits
		,@intNoOfUnitsItemUOMId = intNoOfUnitsItemUOMId
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
			,strReferenceNo NVARCHAR(50)
			,strLotAlias NVARCHAR(50)
			,strVesselNo NVARCHAR(50)
			,dblActualQuantity NUMERIC(18, 6)
			,dblNoOfUnits NUMERIC(18, 6)
			,intNoOfUnitsItemUOMId INT
			)

	BEGIN TRANSACTION

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @strWorkOrderNo IS NULL
		OR @strWorkOrderNo = ''
	BEGIN
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = 8
			,@intBlendRequirementId = NULL
			,@intPatternCode = 70
			,@ysnProposed = 0
			,@strPatternString = @strWorkOrderNo OUTPUT
	END

	IF @intManufacturingCellId IS NULL
	BEGIN
		SELECT @intExecutionOrder = MAX(intExecutionOrder) + 1
		FROM dbo.tblMFWorkOrder
		WHERE dtmPlannedDate = @dtmPlannedDate
	END
	ELSE
	BEGIN
		SELECT @intExecutionOrder = MAX(intExecutionOrder) + 1
		FROM dbo.tblMFWorkOrder
		WHERE dtmPlannedDate = @dtmPlannedDate
			AND intManufacturingCellId = @intManufacturingCellId
	END

	SELECT @ysnKittingEnabled = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 27 --PM Staging Location

	SELECT @intAttributeTypeId = intAttributeTypeId
	FROM tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	IF @intAttributeTypeId = 2
	BEGIN
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 46
			,@ysnProposed = 0
			,@strPatternString = @strDemandNo OUTPUT

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		INSERT INTO tblMFBlendRequirement (
			strDemandNo
			,intItemId
			,dblQuantity
			,intUOMId
			,dtmDueDate
			,intLocationId
			,intStatusId
			,dblIssuedQty
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intMachineId
			)
		VALUES (
			@strDemandNo
			,@intItemId
			,@dblQuantity
			,@intUnitMeasureId
			,@dtmPlannedDate
			,@intLocationId
			,2
			,@dblQuantity
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,NULL
			)

		SELECT @intBlendRequirementId = SCOPE_IDENTITY()
	END

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
		,ysnKittingEnabled
		,dblPlannedQuantity
		,intKitStatusId
		,intBlendRequirementId
		,strReferenceNo
		,strLotAlias
		,strVesselNo
		,dblActualQuantity
		,dblNoOfUnits
		,intNoOfUnitsItemUOMId
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
		,0
		,@dblQuantity
		,CASE 
			WHEN @ysnKittingEnabled = 1
				THEN 6
			ELSE NULL
			END
		,@intBlendRequirementId
		,@strReferenceNo
		,@strLotAlias
		,@strVesselNo
		,@dblActualQuantity
		,@dblNoOfUnits
		,@intNoOfUnitsItemUOMId

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
		,ISNULL((
				SELECT MAX(intSequenceNo)
				FROM dbo.tblMFWorkOrderInputLot
				WHERE intWorkOrderId = @intWorkOrderId
				), 0) + 1
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,dblQty NUMERIC(38, 20)
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
		,ysnStaged
		)
	SELECT @intWorkOrderId
		,intLotId
		,intItemId
		,dblWeight
		,intWeightUOMId
		,dblQty
		,intItemUOMId
		,ISNULL((
				SELECT MAX(intSequenceNo)
				FROM dbo.tblMFWorkOrderConsumedLot
				WHERE intWorkOrderId = @intWorkOrderId
				), 0) + 1
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,ysnStaged
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,intUserId INT
			,ysnStaged BIT
			) x

	SELECT @intWorkOrderConsumedLotId = SCOPE_IDENTITY()

	IF @intStatusId = 10
	BEGIN
		EXEC dbo.uspMFCopyRecipe @intItemId = @intItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId
	END

	IF @intAttributeTypeId = 2
		GOTO X

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
		,@strItemNo NVARCHAR(50)
		,@intSanitizationStagingUnitId INT

	SELECT @intOwnerId = IO.intOwnerId
	FROM dbo.tblICItemOwner IO
	WHERE intItemId IN (
			SELECT intItemId
			FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (intItemId INT) x
			)

	SELECT @intSanitizationStagingUnitId = intSanitizationStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @intEntityId = E.intEntityId
	FROM dbo.tblEMEntity E
	JOIN dbo.[tblEMEntityType] ET ON E.intEntityId = ET.intEntityId
	WHERE ET.strType = 'Customer'
		AND E.strName = 'Production'

	SELECT @intOrderTermsId = intOrderTermsId
	FROM tblWHOrderTerms
	WHERE ysnDefault = 1

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @intUserId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = @intManufacturingCellId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = 8
		,@intBlendRequirementId = NULL
		,@intPatternCode = 75
		,@ysnProposed = 0
		,@strPatternString = @strBOLNo OUTPUT

	DECLARE @tblWHOrderHeader TABLE (intOrderHeaderId INT)

	IF @intOwnerId IS NULL
	BEGIN
		SELECT @strItemNo = I.strItemNo
		FROM dbo.tblICItem I
		WHERE intItemId IN (
				SELECT intItemId
				FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (intItemId INT) x
				)

		RAISERROR (
				'Owner is not configured for the item %s.'
				,14
				,1
				,@strItemNo
				)
	END

	SELECT @strXML = '<root>'

	SELECT @strXML += '<intOrderStatusId>1</intOrderStatusId>'

	SELECT @strXML += '<intOrderTypeId>8</intOrderTypeId>'

	SELECT @strXML += '<intOrderDirectionId>2</intOrderDirectionId>'

	SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

	SELECT @strXML += '<strReferenceNo>' + @strWorkOrderNo + '</strReferenceNo>'

	SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCurrentDate) + '</dtmRAD>'

	SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

	SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intSanitizationStagingUnitId) + '</intStagingLocationId>'

	SELECT @strXML += '<intFreightTermId>' + LTRIM(@intOrderTermsId) + '</intFreightTermId>'

	SELECT @strXML += '<intShipFromAddressId>' + LTRIM(@intLocationId) + '</intShipFromAddressId>'

	SELECT @strXML += '<intShipToAddressId>' + LTRIM(@intEntityId) + '</intShipToAddressId>'

	SELECT @strXML += '<strLastUpdateBy>' + LTRIM(@strUserName) + ' </strLastUpdateBy>'

	SELECT @strXML += '</root>'

	INSERT INTO @tblWHOrderHeader
	EXEC dbo.uspWHCreateOutboundOrder @strXML = @strXML

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
		,intConcurrencyId
		,ysnIsWeightCertified
		)
	SELECT @intOrderHeaderId
		,CL.intItemId
		,CL.dblIssuedQuantity
		,IU1.intUnitMeasureId
		,CL.intCreatedUserId
		,CL.dtmCreated
		,CL.dblIssuedQuantity
		,ISNULL((NULL), I.intUnitPerLayer)
		,ISNULL((NULL), I.intLayerPerPallet)
		,intSequenceNo
		,CL.dblIssuedQuantity
		,IU1.intUnitMeasureId
		,CL.dblQuantity / CL.dblIssuedQuantity
		,IU.intUnitMeasureId
		,@dtmCurrentDate
		,L.strLotAlias
		,CL.intWorkOrderInputLotId
		,L.intLotId
		,1
		,1
	FROM dbo.tblMFWorkOrderInputLot CL
	JOIN dbo.tblICLot L ON L.intLotId = CL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = CL.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = CL.intItemUOMId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = CL.intItemIssuedUOMId
	WHERE CL.intWorkOrderId = @intWorkOrderId

	X:

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



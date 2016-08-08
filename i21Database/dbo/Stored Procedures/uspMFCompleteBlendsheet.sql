CREATE PROCEDURE [dbo].[uspMFCompleteBlendSheet] (
	@strXml NVARCHAR(MAX)
	,@intLotId INT = 0 OUT
	,@strLotNumber NVARCHAR(50) = '' OUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId INT
		,@dblQtyToProduce NUMERIC(38,20)
		,@intItemUOMId INT
		,@dblIssuedQuantity NUMERIC(38,20)
		,@intItemIssuedUOMId INT
		,@dblWeightPerUnit NUMERIC(38,20)
		,@intUserId INT
		,@strRetBatchId NVARCHAR(40)
		,@intStatusId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strProduceXml NVARCHAR(Max)
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@strOutputLotNumber NVARCHAR(50)
		,@intAttributeId INT
		,@ysnIsNegativeQuantityAllowed BIT
		,@strIsNegativeQuantityAllowed NVARCHAR(50)
		,@dtmCurrentDate DATETIME = GetDate()
		,@intLotStatusId INT
		,@strVesselNo NVARCHAR(50)
		,@intRetLotId INT
		,@strLotTracking NVARCHAR(50)
		,@intExecutionOrder INT
		,@intCellId INT
		,@intCategoryId INT
		,@strDemandNo NVARCHAR(50)
		,@intBlendRequirementId INT
		,@intUOMId INT
		,@dblPlannedQuantity NUMERIC(18, 6)
		,@intMachineId INT
		,@dblBlendBinSize NUMERIC(18, 6)
		,@intBatchId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intWorkOrderId = ISNULL(intWorkOrderId, 0)
		,@intItemId = intItemId
		,@dblQtyToProduce = dblQtyToProduce
		,@intItemUOMId = intItemUOMId
		,@dblIssuedQuantity = dblIssuedQuantity
		,@intItemIssuedUOMId = intItemIssuedUOMId
		,@dblWeightPerUnit = dblWeightPerUnit
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strVesselNo = strVesselNo
		,@intCellId = intManufacturingCellId
		,@dblPlannedQuantity = dblPlannedQuantity
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intItemId INT
			,dblQtyToProduce NUMERIC(38,20)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(38,20)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(38,20)
			,intUserId INT
			,intLocationId INT
			,intStorageLocationId INT
			,strVesselNo NVARCHAR(50)
			,intManufacturingCellId INT
			,dblPlannedQuantity NUMERIC(18, 6)
			)

	SELECT @dtmCurrentDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

	IF @dtmCurrentDate IS NULL
	BEGIN
		SELECT @dtmCurrentDate = GetDate()
	END

	IF @intWorkOrderId > 0
	BEGIN
		SELECT @intStatusId = intStatusId
			,@strWorkOrderNo = strWorkOrderNo
			,@intManufacturingProcessId = ISNULL(intManufacturingProcessId, 0)
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF @intManufacturingProcessId = 0
			SELECT TOP 1 @intManufacturingProcessId = intManufacturingProcessId
			FROM tblMFWorkOrderRecipe
			WHERE intWorkOrderId = @intWorkOrderId

		IF (@intStatusId <> 12)
		BEGIN
			SET @strErrMsg = 'Blend Sheet ' + @strWorkOrderNo + ' is either not staged or already produced. Please reload the blend sheet.'

			RAISERROR (
					@strErrMsg
					,16
					,1
					)
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFRecipe
		WHERE intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND ysnActive = 1
	END

	SELECT @intSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @intLotStatusId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE pa.intManufacturingProcessId = @intManufacturingProcessId
		AND pa.intLocationId = @intLocationId
		AND at.strAttributeName = 'Produce Lot Status'

	IF @intLotStatusId = 0
		OR @intLotStatusId IS NULL
		SET @intLotStatusId = 1

	IF @dblIssuedQuantity = 0
	BEGIN
		SET @dblIssuedQuantity = @dblQtyToProduce
		SET @intItemIssuedUOMId = @intItemUOMId
		SET @dblWeightPerUnit = 1
	END

	SELECT @strLotTracking = strLotTracking
		,@intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @intUOMId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intItemUOMId

	BEGIN TRANSACTION

	--Simple Blend Production
	IF @intWorkOrderId = 0
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
			)
		VALUES (
			@strDemandNo
			,@intItemId
			,@dblPlannedQuantity
			,@intUOMId
			,@dtmCurrentDate
			,@intLocationId
			,2
			,@dblPlannedQuantity
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			)

		SELECT @intBlendRequirementId = SCOPE_IDENTITY()

		SELECT @intExecutionOrder = Count(1)
		FROM tblMFWorkOrder
		WHERE intManufacturingCellId = @intCellId
			AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmCurrentDate)
			AND intBlendRequirementId IS NOT NULL
			AND intStatusId NOT IN (
				2
				,13
				)

		SET @intExecutionOrder = @intExecutionOrder + 1

		SELECT @strWorkOrderNo = convert(VARCHAR, @strDemandNo) + right('00' + Convert(VARCHAR, (Max(Cast(right(strWorkOrderNo, 2) AS INT))) + 1), 2)
		FROM tblMFWorkOrder
		WHERE strWorkOrderNo LIKE @strDemandNo + '%'

		IF ISNULL(@strWorkOrderNo, '') = ''
			SET @strWorkOrderNo = convert(VARCHAR, @strDemandNo) + '01'

		SELECT TOP 1 @intMachineId = m.intMachineId
			,@dblBlendBinSize = mp.dblMachineCapacity
		FROM tblMFMachine m
		JOIN tblMFMachinePackType mp ON m.intMachineId = mp.intMachineId
		JOIN tblMFManufacturingCellPackType mcp ON mp.intPackTypeId = mcp.intPackTypeId
		JOIN tblMFManufacturingCell mc ON mcp.intManufacturingCellId = mc.intManufacturingCellId
		JOIN tblMFPackType pk ON mp.intPackTypeId = pk.intPackTypeId
		WHERE pk.intPackTypeId = (
				SELECT intPackTypeId
				FROM tblICItem
				WHERE intItemId = @intItemId
				)
			AND mc.intManufacturingCellId = @intCellId

		INSERT INTO tblMFWorkOrder (
			strWorkOrderNo
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStatusId
			,intManufacturingCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmExpectedDate
			,intExecutionOrder
			,intProductionTypeId
			,dblPlannedQuantity
			,intBlendRequirementId
			,ysnKittingEnabled
			,intKitStatusId
			,ysnUseTemplate
			,strComment
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,dtmReleasedDate
			,intManufacturingProcessId
			,intConcurrencyId
			)
		SELECT @strWorkOrderNo
			,@intItemId
			,@dblPlannedQuantity
			,@intItemUOMId
			,10
			,@intCellId
			,@intMachineId
			,@intLocationId
			,@dblBlendBinSize
			,@dtmCurrentDate
			,@intExecutionOrder
			,1
			,@dblPlannedQuantity
			,@intBlendRequirementId
			,0
			,NULL
			,0
			,''
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intManufacturingProcessId
			,1

		SELECT @intWorkOrderId = SCOPE_IDENTITY()

		--Copy Recipe
		EXEC uspMFCopyRecipe @intItemId
			,@intLocationId
			,@intUserId
			,@intWorkOrderId

		-- Update intWorkOrderId in XML variable
		SELECT @strXml = REPLACE(@strXml, '<intWorkOrderId>0</intWorkOrderId>', '<intWorkOrderId>' + CONVERT(VARCHAR, @intWorkOrderId) + '</intWorkOrderId>')

		--Consume Lots
		EXEC [uspMFEndBlendSheet] @strXml
	END

	IF @strLotTracking = 'No'
	BEGIN
		SELECT @strRetBatchId = strBatchId
			,@intBatchId = intBatchID
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		if @intStorageLocationId=0
			Set @intStorageLocationId=NULL

		Insert Into tblMFWorkOrderProducedLot(intWorkOrderId,intItemId,dblQuantity,intItemUOMId,dblPhysicalCount,intPhysicalItemUOMId,dblWeightPerUnit,
		intStorageLocationId,intBatchId,strBatchId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmProductionDate,intConcurrencyId)
		Values(@intWorkOrderId,@intItemId,@dblQtyToProduce,@intItemUOMId,@dblIssuedQuantity,@intItemIssuedUOMId,@dblWeightPerUnit,
		@intStorageLocationId,@intBatchId,@strRetBatchId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,1)

		EXEC uspMFPostProduction 1
			,0
			,@intWorkOrderId
			,@intItemId
			,@intUserId
			,NULL
			,@intStorageLocationId
			,@dblQtyToProduce
			,@intItemUOMId
			,@dblWeightPerUnit
			,@dblIssuedQuantity
			,@intItemIssuedUOMId
			,@strRetBatchId
			,''
			,@intBatchId
			,@intRetLotId OUT
			,''
			,''
			,''
			,''
			,@dtmCurrentDate
	END
	ELSE
	BEGIN
		EXEC uspMFUpdateBlendProductionDetail @strXml = @strXml

		SET @strProduceXml = '<root>'
		SET @strProduceXml = @strProduceXml + '<intWorkOrderId>' + convert(VARCHAR, @intWorkOrderId) + '</intWorkOrderId>'
		SET @strProduceXml = @strProduceXml + '<intManufacturingProcessId>' + convert(VARCHAR, @intManufacturingProcessId) + '</intManufacturingProcessId>'
		SET @strProduceXml = @strProduceXml + '<intStatusId>' + convert(VARCHAR, 12) + '</intStatusId>'
		SET @strProduceXml = @strProduceXml + '<intItemId>' + convert(VARCHAR, @intItemId) + '</intItemId>'
		SET @strProduceXml = @strProduceXml + '<dblProduceQty>' + convert(VARCHAR, @dblQtyToProduce) + '</dblProduceQty>'
		SET @strProduceXml = @strProduceXml + '<intProduceUnitMeasureId>' + convert(VARCHAR, @intItemUOMId) + '</intProduceUnitMeasureId>'
		--If @dblIssuedQuantity>0
		--Begin
		SET @strProduceXml = @strProduceXml + '<dblPhysicalCount>' + convert(VARCHAR, @dblIssuedQuantity) + '</dblPhysicalCount>'
		SET @strProduceXml = @strProduceXml + '<intPhysicalItemUOMId>' + convert(VARCHAR, @intItemIssuedUOMId) + '</intPhysicalItemUOMId>'
		SET @strProduceXml = @strProduceXml + '<dblUnitQty>' + convert(VARCHAR, @dblWeightPerUnit) + '</dblUnitQty>'
		--End
		SET @strProduceXml = @strProduceXml + '<strVesselNo>' + convert(VARCHAR, @strVesselNo) + '</strVesselNo>'
		SET @strProduceXml = @strProduceXml + '<intUserId>' + convert(VARCHAR, @intUserId) + '</intUserId>'
		--Set @strProduceXml=@strProduceXml + '<strOutputLotNumber>' + convert(varchar,'') + '</strOutputLotNumber>'
		SET @strProduceXml = @strProduceXml + '<intLocationId>' + convert(VARCHAR, @intLocationId) + '</intLocationId>'
		SET @strProduceXml = @strProduceXml + '<intSubLocationId>' + convert(VARCHAR, @intSubLocationId) + '</intSubLocationId>'
		SET @strProduceXml = @strProduceXml + '<intStorageLocationId>' + convert(VARCHAR, @intStorageLocationId) + '</intStorageLocationId>'
		--Set @strProduceXml=@strProduceXml + '<ysnSubLotAllowed>' + convert(varchar,@intWorkOrderId) + '</ysnSubLotAllowed>'
		SET @strProduceXml = @strProduceXml + '<intProductionTypeId>' + convert(VARCHAR, 2) + '</intProductionTypeId>'
		SET @strProduceXml = @strProduceXml + '<strLotAlias>' + convert(VARCHAR, @strWorkOrderNo) + '</strLotAlias>'
		SET @strProduceXml = @strProduceXml + '<strVendorLotNo>' + convert(VARCHAR, @strVesselNo) + '</strVendorLotNo>'
		SET @strProduceXml = @strProduceXml + '<intLotStatusId>' + convert(VARCHAR, @intLotStatusId) + '</intLotStatusId>'
		SET @strProduceXml = @strProduceXml + '<dtmPlannedDate>' + convert(VARCHAR, @dtmCurrentDate) + '</dtmPlannedDate>'
		SET @strProduceXml = @strProduceXml + '<ysnIgnoreTolerance>0</ysnIgnoreTolerance>'
		SET @strProduceXml = @strProduceXml + '</root>'

		EXEC uspMFCompleteWorkOrder @strXML = @strProduceXml
			,@strOutputLotNumber = @strOutputLotNumber OUT
	END

	UPDATE tblMFWorkOrder
	SET intStatusId = 13
		,dtmActualProductionEndDate = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = @dtmCurrentDate
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intBatchId = intBatchId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFWorkOrderConsumedLot
	SET intBatchId = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	IF @strLotTracking <> 'No'
	BEGIN
		SELECT TOP 1 @intLotId = ISNULL(intLotId, 0)
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId = @intWorkOrderId

		SET @strLotNumber = ISNULL(@strOutputLotNumber, '')
	END
	ELSE
	BEGIN
		SET @intLotId = 0
		SET @strLotNumber = ''
	END

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

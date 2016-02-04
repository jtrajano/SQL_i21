CREATE PROCEDURE [dbo].[uspMFCompleteBlendSheet] (@strXml NVARCHAR(MAX),@intLotId int=0 OUT,@strLotNumber nvarchar(50)='' OUT)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId INT
		,@dblQtyToProduce NUMERIC(18, 6)
		,@intItemUOMId INT
		,@dblIssuedQuantity NUMERIC(18, 6)
		,@intItemIssuedUOMId INT
		,@dblWeightPerUnit NUMERIC(18, 6)
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
		,@strLotTracking nvarchar(50)
		,@intExecutionOrder INT
		,@intCellId INT
		,@intCategoryId INT
		,@strDemandNo NVARCHAR(50)
		,@intBlendRequirementId INT
		,@intUOMId INT
		,@dblPlannedQuantity NUMERIC(18,6)
		,@intMachineId INT
		,@dblBlendBinSize NUMERIC(18,6)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intWorkOrderId = ISNULL(intWorkOrderId,0)
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
			,dblQtyToProduce NUMERIC(18, 6)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(18, 6)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(18, 6)
			,intUserId INT
			,intLocationId INT
			,intStorageLocationId INT
			,strVesselNo NVARCHAR(50)
			,intManufacturingCellId INT
			,dblPlannedQuantity NUMERIC(18, 6)
			)

	If @intWorkOrderId > 0
	Begin
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
	End
	Else
	Begin
		Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFRecipe Where intItemId=@intItemId AND intLocationId=@intLocationId AND ysnActive=1
	End

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

	Select @strLotTracking=strLotTracking,@intCategoryId=intCategoryId From tblICItem Where intItemId=@intItemId
	Select @intUOMId=intUnitMeasureId From tblICItemUOM Where intItemUOMId=@intItemUOMId

	BEGIN TRANSACTION

	--Simple Blend Production
	If @intWorkOrderId=0
	Begin
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

		Insert Into tblMFBlendRequirement(strDemandNo,intItemId,dblQuantity,intUOMId,dtmDueDate,intLocationId,intStatusId,dblIssuedQty,
		intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
		Values(@strDemandNo,@intItemId,@dblPlannedQuantity,@intUOMId,@dtmCurrentDate,@intLocationId,2,@dblPlannedQuantity,
		@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate)

		Select @intBlendRequirementId=SCOPE_IDENTITY()

		Select @intExecutionOrder = Count(1) From tblMFWorkOrder Where intManufacturingCellId=@intCellId 
		And convert(date,dtmExpectedDate)=convert(date,@dtmCurrentDate) And intBlendRequirementId is not null
		And intStatusId Not in (2,13)

		Set @intExecutionOrder=@intExecutionOrder+1

		Select @strWorkOrderNo= convert(varchar,@strDemandNo) + right('00' + Convert(varchar,(Max(Cast(right(strWorkOrderNo,2) as int)))+1),2)  
		from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%'

		if ISNULL(@strWorkOrderNo,'')=''
			Set @strWorkOrderNo=convert(varchar,@strDemandNo) + '01'

		Select TOP 1 @intMachineId=m.intMachineId,@dblBlendBinSize=mp.dblMachineCapacity 
		From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
		Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
		Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
		Join tblMFPackType pk on mp.intPackTypeId=pk.intPackTypeId 
		Where pk.intPackTypeId=(Select intPackTypeId From tblICItem Where intItemId=@intItemId)
		And mc.intManufacturingCellId=@intCellId

		insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
		intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,intKitStatusId,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,intManufacturingProcessId,intConcurrencyId)
		Select @strWorkOrderNo,@intItemId,@dblPlannedQuantity,@intItemUOMId,10,@intCellId,@intMachineId,@intLocationId,@dblBlendBinSize,@dtmCurrentDate,@intExecutionOrder,1,
		@dblPlannedQuantity,@intBlendRequirementId,0,null,0,'',@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intManufacturingProcessId,1

		Select @intWorkOrderId=SCOPE_IDENTITY()

		--Copy Recipe
		Exec uspMFCopyRecipe @intItemId,@intLocationId,@intUserId,@intWorkOrderId

		-- Update intWorkOrderId in XML variable
		Select @strXml=REPLACE(@strXml,'<intWorkOrderId>0</intWorkOrderId>','<intWorkOrderId>' + CONVERT(varchar,@intWorkOrderId) + '</intWorkOrderId>')

		--Consume Lots
		Exec [uspMFEndBlendSheet] @strXml
	End

	If @strLotTracking='No' 
	Begin
			Select @strRetBatchId=strBatchId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

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
			,0
			,@intRetLotId OUT
			,''
			,''
			,''
			,''
	End
	Else
	Begin
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
		SET @strProduceXml = @strProduceXml + '<ysnIgnoreTolerance>0</ysnIgnoreTolerance>'
		SET @strProduceXml = @strProduceXml + '</root>'

		EXEC uspMFCompleteWorkOrder @strXML = @strProduceXml
			,@strOutputLotNumber = @strOutputLotNumber OUT
	End

	UPDATE tblMFWorkOrder
	SET intStatusId = 13
		,dtmActualProductionEndDate = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = @dtmCurrentDate
	WHERE intWorkOrderId = @intWorkOrderId

	DECLARE @intBatchId INT

	SELECT @intBatchId = intBatchId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFWorkOrderConsumedLot
	SET intBatchId = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	If @strLotTracking<>'No'
	Begin
		Select TOP 1 @intLotId=ISNULL(intLotId,0) From tblMFWorkOrderProducedLot Where intWorkOrderId=@intWorkOrderId
		Set @strLotNumber=ISNULL(@strOutputLotNumber,'')
	End
	Else
	Begin
		Set @intLotId=0
		Set @strLotNumber=''
	End

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

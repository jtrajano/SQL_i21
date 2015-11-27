CREATE PROCEDURE [dbo].[uspMFCompleteBlendSheet] (@strXml NVARCHAR(MAX))
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
		,@strWONo NVARCHAR(50)
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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intWorkOrderId = intWorkOrderId
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
			)

	SELECT @intStatusId = intStatusId
		,@strWONo = strWorkOrderNo
		,@intManufacturingProcessId = ISNULL(intManufacturingProcessId, 0)
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intManufacturingProcessId = 0
		SELECT TOP 1 @intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

	IF (@intStatusId <> 12)
	BEGIN
		SET @strErrMsg = 'Blend Sheet ' + @strWONo + ' is either not staged or already produced. Please reload the blend sheet.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
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

	BEGIN TRANSACTION

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
	SET @strProduceXml = @strProduceXml + '<strLotAlias>' + convert(VARCHAR, @strWONo) + '</strLotAlias>'
	SET @strProduceXml = @strProduceXml + '<strVendorLotNo>' + convert(VARCHAR, @strVesselNo) + '</strVendorLotNo>'
	SET @strProduceXml = @strProduceXml + '<intLotStatusId>' + convert(VARCHAR, @intLotStatusId) + '</intLotStatusId>'
	SET @strProduceXml = @strProduceXml + '<ysnIgnoreTolerance>0</ysnIgnoreTolerance>'
	SET @strProduceXml = @strProduceXml + '</root>'

	EXEC uspMFCompleteWorkOrder @strXML = @strProduceXml
		,@strOutputLotNumber = @strOutputLotNumber OUT

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

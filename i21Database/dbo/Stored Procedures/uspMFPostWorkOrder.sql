CREATE PROCEDURE uspMFPostWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblProduceQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@strRetBatchId NVARCHAR(40)
		,@intBatchId INT
		,@intWorkOrderId INT
		,@ysnNegativeQtyAllowed BIT
		,@intUserId INT
		,@dtmCurrentDateTime DATETIME
		,@intTransactionCount INT
		,@intAttributeId int
		,@strYieldAdjustmentAllowed nvarchar(50)
		,@ysnExcessConsumptionAllowed int
		,@intManufacturingProcessId int
		,@intLocationId int

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = Getdate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,ysnNegativeQtyAllowed BIT
			,intUserId INT
			)

	SELECT @dblProduceQty = SUM(dblQuantity)
		,@intItemUOMId = MIN(intItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	EXEC dbo.uspMFValidatePostWorkOrder @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId
	
	If @dblProduceQty>0
	Begin
		Select @intManufacturingProcessId=intManufacturingProcessId, @intLocationId=intLocationId From dbo.tblMFWorkOrder Where intWorkOrderId =@intWorkOrderId 

		Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Yield Adjustment Allowed'

		Select @strYieldAdjustmentAllowed=strAttributeValue
		From tblMFManufacturingProcessAttribute
		Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

		Select @ysnExcessConsumptionAllowed=0
		If @strYieldAdjustmentAllowed='True'
		Begin
			Select @ysnExcessConsumptionAllowed=1
		End

		EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
			,@dblProduceQty = @dblProduceQty
			,@intProduceUOMKey = @intItemUOMId
			,@intBatchId = @intBatchId
			,@intUserId = @intUserId
			,@PickPreference='Substitute Item'
			,@ysnExcessConsumptionAllowed=@ysnExcessConsumptionAllowed

		EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
			,@dblProduceQty = @dblProduceQty
			,@intProduceUOMKey = @intItemUOMId
			,@intUserId = @intUserId
			,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
			,@strRetBatchId = @strRetBatchId OUTPUT
			,@ysnPostConsumption = 1
	End

	EXEC dbo.uspMFCalculateYield @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId
	
	IF @intTransactionCount = 0
	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
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

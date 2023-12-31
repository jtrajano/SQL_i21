CREATE PROCEDURE [dbo].[uspMFConsumeWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@ysnNegativeQtyAllowed INT = 0
	,@strRetBatchId NVARCHAR(40) = NULL OUT
	,@ysnPostConsumption BIT = 0
	,@intBatchId INT
	,@ysnPostGL BIT=1
	)
AS
BEGIN
	DECLARE @ConsumeDataKey INT
		,@intLotId INT
		,@dblQuantity NUMERIC(38, 20)
		,@intItemUOMId INT
		,@intLotTransactionId INT

	DECLARE @ConsumeData TABLE (
		ConsumeDataKey INT IDENTITY(1, 1)
		,intLotId INT
		,dblQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		)

	INSERT INTO @ConsumeData (
		intLotId
		,dblQuantity
		,intItemUOMId
		)
	SELECT intLotId
		,SUM(dblQuantity)
		,MIN(intItemUOMId)
	FROM tblMFWorkOrderConsumedLot WI
	WHERE WI.intWorkOrderId = @intWorkOrderId
		AND ISNULL(intBatchId, @intBatchId) = @intBatchId
	Group by intLotId

	SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
	FROM @ConsumeData

	WHILE (@ConsumeDataKey > 0)
	BEGIN
		SELECT @intLotId = intLotId
			,@dblQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
		FROM @ConsumeData
		WHERE ConsumeDataKey = @ConsumeDataKey

		EXEC dbo.uspMFValidateConsumeLot @intLotId = @intLotId
			,@dblConsumeQty = @dblQuantity
			,@intConsumeUOMKey = @intItemUOMId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId
			,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed

		SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
		FROM @ConsumeData
		WHERE ConsumeDataKey > @ConsumeDataKey
	END
	Declare @intAttributeTypeId int, @intManufacturingProcessId int

	Select @intManufacturingProcessId=intManufacturingProcessId from tblMFWorkOrder Where intWorkOrderId =@intWorkOrderId 

	Select @intAttributeTypeId=intAttributeTypeId
	from dbo.tblMFManufacturingProcess 
	Where intManufacturingProcessId=@intManufacturingProcessId

	IF 
			@intAttributeTypeId=2
		
		OR @ysnPostConsumption = 1
	BEGIN
		EXEC uspMFPostConsumption 1
			,0
			,@intWorkOrderId
			,@intUserId
			,NULL
			,@strRetBatchId OUT
			,@intBatchId
			,@ysnPostGL
	END
END

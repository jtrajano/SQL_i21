
CREATE PROCEDURE [dbo].[uspMFConsumeWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@strRetBatchId nvarchar(40)=NULL OUT
	)
AS
BEGIN
	DECLARE @ConsumeDataKey INT
		,@intLotId INT
		,@dblQuantity NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intWorkOrderConsumedLotId INT
		,@intLotTransactionId INT
		
	DECLARE @ConsumeData TABLE (
		ConsumeDataKey INT IDENTITY(1, 1)
		,intLotId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,intWorkOrderConsumedLotId INT
		)

	INSERT INTO @ConsumeData (
		intLotId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderConsumedLotId
		)
	SELECT intLotId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderConsumedLotId
	FROM tblMFWorkOrderConsumedLot WI
	WHERE WI.intWorkOrderId = @intWorkOrderId

	SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
	FROM @ConsumeData
	
	WHILE (@ConsumeDataKey > 0)
	BEGIN
		SELECT @intLotId = intLotId
			,@dblQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
			,@intWorkOrderConsumedLotId = intWorkOrderConsumedLotId
		FROM @ConsumeData
		WHERE ConsumeDataKey = @ConsumeDataKey

		EXEC dbo.uspICValidateConsumeLot @intLotId =@intLotId
										,@dblConsumeQty =@dblQuantity
										,@intConsumeUOMKey =@intItemUOMId
										,@intUserId =@intUserId
										,@intWorkOrderId =@intWorkOrderId
										,@ysnNegativeQtyAllowed=0
	
		SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
		FROM @ConsumeData
		WHERE ConsumeDataKey > @ConsumeDataKey
	END

	Exec uspMFPostConsumption 1,0,@intWorkOrderId,@intUserId,null,@strRetBatchId OUT

END


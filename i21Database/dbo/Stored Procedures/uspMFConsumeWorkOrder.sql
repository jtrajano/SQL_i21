CREATE PROCEDURE [dbo].[uspMFConsumeWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@ysnNegativeQtyAllowed INT = 0
	,@strRetBatchId NVARCHAR(40) = NULL OUT
	,@ysnPostConsumption BIT = 0
	,@intBatchId INT
	)
AS
BEGIN
	DECLARE @ConsumeDataKey INT
		,@intLotId INT
		,@dblQuantity NUMERIC(38, 20)
		,@intItemUOMId INT
		,@intWorkOrderConsumedLotId INT
		,@intLotTransactionId INT
	DECLARE @ConsumeData TABLE (
		ConsumeDataKey INT IDENTITY(1, 1)
		,intLotId INT
		,dblQuantity NUMERIC(38, 20)
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
		AND ISNULL(intBatchId, @intBatchId) = @intBatchId

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

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
				AND intBlendRequirementId IS NOT NULL
			)
		OR @ysnPostConsumption = 1
	BEGIN
		EXEC uspMFPostConsumption 1
			,0
			,@intWorkOrderId
			,@intUserId
			,NULL
			,@strRetBatchId OUT
			,@intBatchId
	END
END

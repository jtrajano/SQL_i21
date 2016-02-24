
CREATE PROCEDURE [dbo].[uspMFConsumeWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@ysnNegativeQtyAllowed int=0
	,@strRetBatchId nvarchar(40)=NULL OUT
	,@ysnPostConsumption bit=0
	,@intBatchId int
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
	WHERE WI.intWorkOrderId = @intWorkOrderId and ISNULL(intBatchId,@intBatchId)=@intBatchId

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

		EXEC dbo.uspMFValidateConsumeLot @intLotId =@intLotId
										,@dblConsumeQty =@dblQuantity
										,@intConsumeUOMKey =@intItemUOMId
										,@intUserId =@intUserId
										,@intWorkOrderId =@intWorkOrderId
										,@ysnNegativeQtyAllowed=@ysnNegativeQtyAllowed
	
		SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
		FROM @ConsumeData
		WHERE ConsumeDataKey > @ConsumeDataKey
	END

	If exists(Select *from tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId and intBlendRequirementId is not null) or @ysnPostConsumption =1
	Begin
		Exec uspMFPostConsumption 1,0,@intWorkOrderId,@intUserId,null,@strRetBatchId OUT
	End

END


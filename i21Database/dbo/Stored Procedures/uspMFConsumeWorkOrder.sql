CREATE PROCEDURE [dbo].[uspMFConsumeWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@ysnNegativeQtyAllowed INT = 0
	,@strRetBatchId NVARCHAR(40) = NULL OUT
	,@ysnPostConsumption BIT = 0
	,@intBatchId INT
	,@ysnPostGL BIT = 1
	,@ysnRecap BIT = 0
	,@dtmDate DATETIME = NULL
	,@intManufacturingProcessId int=NULL
	,@intLocationId int=NULL
	)
AS
BEGIN
	DECLARE @ConsumeDataKey INT
		,@intLotId INT
		,@dblQuantity NUMERIC(38, 20)
		,@intItemUOMId INT
		,@intLotTransactionId INT
		,@intAdjustmentId int
		,@dblQty NUMERIC(38, 20)
		,@strLastBagAdjustment nvarchar(50)
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
		AND IsNULL(WI.ysnPosted, 0) = 0
	GROUP BY intLotId

	SELECT @ConsumeDataKey = MIN(ConsumeDataKey)
	FROM @ConsumeData

	IF @ConsumeDataKey IS NULL
	BEGIN
		RETURN
	END

	SELECT @strLastBagAdjustment = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 128

	if @strLastBagAdjustment is null or @strLastBagAdjustment=''
	Begin
		Select @strLastBagAdjustment='False'
	End

	WHILE (@ConsumeDataKey > 0)
	BEGIN
		SELECT @intLotId = NULL
			,@dblQuantity = NULL
			,@intItemUOMId =NULL
			,@dblQty=NULL

		SELECT @intLotId = intLotId
			,@dblQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
		FROM @ConsumeData
		WHERE ConsumeDataKey = @ConsumeDataKey

		IF @strLastBagAdjustment = 'True'
		BEGIN
			SELECT @dblQty = (
					CASE 
						WHEN IsNULL(dblWeight, 0) = 0
							THEN dblQty
						ELSE dblWeight
						END
					)
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId

			IF @dblQty - @dblQuantity < 0
				AND abs(@dblQuantity - @dblQty) < 1
			BEGIN
				EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
					,@dblNewLotQty = @dblQuantity
					,@intAdjustItemUOMId = @intItemUOMId
					,@intUserId = 1
					,@strReasonCode = '90'
					,@blnValidateLotReservation = 0
					,@strNotes = 'Last Bag Adjustment'
					,@dtmDate = NULL
					,@ysnBulkChange = 0
					,@strReferenceNo = NULL
					,@intAdjustmentId = @intAdjustmentId OUTPUT
					,@ysnDifferenceQty = 0
			END
		END

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

	DECLARE @intAttributeTypeId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeTypeId = intAttributeTypeId
	FROM dbo.tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	IF @intAttributeTypeId = 2
		OR @ysnPostConsumption = 1
	BEGIN
		EXEC uspMFPostConsumption 1
			,@ysnRecap
			,@intWorkOrderId
			,@intUserId
			,NULL
			,@strRetBatchId OUT
			,@intBatchId
			,@ysnPostGL
			,NULL
			,@dtmDate
	END
END

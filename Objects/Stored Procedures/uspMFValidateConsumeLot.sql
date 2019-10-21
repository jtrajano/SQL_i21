CREATE PROCEDURE [dbo].uspMFValidateConsumeLot (
	@intLotId INT
	,@dblConsumeQty NUMERIC(38, 20)
	,@intConsumeUOMKey INT
	,@intUserId INT
	,@intWorkOrderId INT
	,@ysnNegativeQtyAllowed BIT = 0
	)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strSecondaryStatus NVARCHAR(50)
		,@dtmExpiryDate DATETIME
		,@intLotStatusId INT
		,@strLotNumber NVARCHAR(50)
		,@intLocationId INT
		,@intStatusId INT
		,@intWOLocationId INT
		,@dblOnHand NUMERIC(38, 20)
		,@strName NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@intProductId INT
		,@dblQuantity NUMERIC(38, 20)
		,@strProductItemNo NVARCHAR(50)
		,@dblTotalQtyToBeConsumed NUMERIC(38, 20)
		,@dblQtyConsumedSoFar NUMERIC(38, 20)
		,@strStatus NVARCHAR(50)
		,@strConsumeQty nvarchar(50)
		,@strOnHand nvarchar(50)


	IF @dblConsumeQty <= 0
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		SELECT @strConsumeQty=@dblConsumeQty
		RAISERROR (
				'The requested consume quantity of %s is invalid. Please attempt to consume a positive quantity less than or equal to input lot quantity.'
				,11
				,1
				,@strConsumeQty
				)

		RETURN
	END

	SELECT @intStatusId = intStatusId
		,@intWOLocationId = intLocationId
		,@intProductId = intItemId
		,@dblQuantity = dblQuantity
	FROM dbo.tblMFWorkOrder W
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strName = strName
	FROM dbo.tblMFWorkOrderStatus
	WHERE intStatusId = @intStatusId

	--IF @strName <> 'Started'
	--BEGIN
	--	RAISERROR (
	--			51081
	--			,11
	--			,1
	--			)

	--	RETURN
	--END

	SELECT @dtmExpiryDate = dtmExpiryDate
		,@intLotStatusId = intLotStatusId
		,@strLotNumber = strLotNumber
		,@intLocationId = intLocationId
		,@dblOnHand = (CASE WHEN intWeightUOMId IS NOT NULL THEN dblWeight ELSE dblQty END)
		,@intItemId = intItemId
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	SELECT @strItemNo = strItemNo
			,@strStatus = strStatus
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @strSecondaryStatus = strSecondaryStatus
	FROM dbo.tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	SELECT @strUnitMeasure = strUnitMeasure
	FROM dbo.tblICUnitMeasure
	WHERE intUnitMeasureId = @intConsumeUOMKey

	IF @strSecondaryStatus <> 'Active'
	BEGIN
		RAISERROR (
				'Lot ''%s'' is in quarantine. You are not allowed to consume a quantity from a quarantined lot.'
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @intWOLocationId <> @intLocationId
	BEGIN
		RAISERROR (
				'The lot ''%s'' is not available for consumption.'
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @dtmExpiryDate IS NOT NULL AND @dtmExpiryDate < GETDATE()
	BEGIN
		RAISERROR (
				'The Lot ''%s'' is expired. You cannot consume.'
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @dblConsumeQty > @dblOnHand
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		SELECT @strConsumeQty=@dblConsumeQty
		Select @strOnHand=@dblOnHand
		RAISERROR (
				'The attempted consumption quantity of %s %s of material ''%s'' from lot ''%s'' is more than the lot''s queued quantity of %s %s. The transaction will not be allowed to proceed.'
				,11
				,1
				,@strConsumeQty
				,@strUnitMeasure
				,@strItemNo
				,@strLotNumber
				,@strOnHand
				,@strUnitMeasure
				)

		RETURN
	END

	IF @strStatus = 'InActive'
	BEGIN
		RAISERROR (
				'The specified item ''%s'' is InActive. The transaction can not proceed.'
				,11
				,1
				,@strItemNo
				)
	END
	--IF @intItemId NOT IN (
	--		SELECT RI.intItemId
	--		FROM dbo.tblMFWorkOrderRecipeItem RI
	--		WHERE RI.intWorkOrderId = @intWorkOrderId
	--			AND RI.intRecipeItemTypeId = 1
				
	--		)
	--	and @intItemId NOT IN (
	--		SELECT RSI.intSubstituteItemId
	--		FROM dbo.tblMFWorkOrderRecipeItem RI 
	--		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
	--		WHERE RI.intWorkOrderId = @intWorkOrderId
	--			AND RI.intRecipeItemTypeId = 1
				
	--		)
	--BEGIN
	--	SELECT @strProductItemNo = strItemNo
	--	FROM dbo.tblICItem
	--	WHERE intItemId = @intProductId

	--	RAISERROR (
	--			51082
	--			,11
	--			,1
	--			,@strItemNo
	--			,@strLotNumber
	--			,@strProductItemNo
	--			)

	--	RETURN
	--END

	--SELECT @dblTotalQtyToBeConsumed = @dblQuantity * RI.dblCalculatedUpperTolerance / R.dblQuantity
	--FROM dbo.tblMFWorkOrdeRecipeItem RI 
	--WHERE RI.intWorkOrderId = @intWorkOrderId
	--	AND RI.intRecipeItemTypeId = 1
	--	AND RI.intItemId = @intItemId

	--IF @dblTotalQtyToBeConsumed IS NULL
	--BEGIN
	--	SELECT @dblTotalQtyToBeConsumed = (@dblQuantity * RI.dblCalculatedUpperTolerance / R.dblQuantity) * RSI.dblSubstituteRatio
	--	FROM dbo.tblMFWorkOrderRecipeItem RI 
	--	JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
	--	WHERE RI.intWorkOrderId = @intWorkOrderId
	--		AND RI.intRecipeItemTypeId = 1
	--		AND RI.intItemId = @intItemId
	--END

	--SELECT @dblQtyConsumedSoFar = SUM(WC.dblQuantity)
	--FROM dbo.tblMFWorkOrderConsumedLot WC
	--JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
	--WHERE intWorkOrderId = @intWorkOrderId
	--	AND L.intItemId = @intItemId

	--IF @dblQtyConsumedSoFar + @dblConsumeQty > @dblTotalQtyToBeConsumed
	--	AND @ysnNegativeQtyAllowed = 0
	--BEGIN
	--	RAISERROR (
	--			51089
	--			,11
	--			,1
	--			,@dblConsumeQty
	--			,@strUnitMeasure
	--			,@strItemNo
	--			,@strLotNumber
	--			,@dblOnHand
	--			,@strUnitMeasure
	--			)

	--	RETURN
	--END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH


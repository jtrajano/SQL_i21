CREATE PROCEDURE [dbo].uspMFValidateConsumeLot (
	@intLotId INT
	,@dblConsumeQty NUMERIC(18, 6)
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
Return
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strSecondaryStatus NVARCHAR(50)
		,@dtmExpiryDate DATETIME
		,@intLotStatusId INT
		,@strLotNumber NVARCHAR(50)
		,@intLocationId INT
		,@intStatusId INT
		,@intWOLocationId INT
		,@dblOnHand NUMERIC(18, 6)
		,@strName NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@intProductId INT
		,@dblQuantity NUMERIC(18, 6)
		,@strProductItemNo NVARCHAR(50)
		,@dblTotalQtyToBeConsumed NUMERIC(18, 6)
		,@dblQtyConsumedSoFar NUMERIC(18, 6)

	IF @dblConsumeQty <= 0
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		RAISERROR (
				51085
				,11
				,1
				,@dblConsumeQty
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

	IF @strName <> 'Started'
	BEGIN
		RAISERROR (
				51081
				,11
				,1
				)

		RETURN
	END

	SELECT @dtmExpiryDate = dtmExpiryDate
		,@intLotStatusId = intLotStatusId
		,@strLotNumber = strLotNumber
		,@intLocationId = intLocationId
		,@dblOnHand = dblWeight
		,@intItemId = intItemId
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	SELECT @strItemNo = strItemNo
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
				51086
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @intWOLocationId <> @intLocationId
	BEGIN
		RAISERROR (
				51087
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @dtmExpiryDate < GETDATE()
	BEGIN
		RAISERROR (
				51088
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @dblConsumeQty > @dblOnHand
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		RAISERROR (
				51089
				,11
				,1
				,@dblConsumeQty
				,@strUnitMeasure
				,@strItemNo
				,@strLotNumber
				,@dblOnHand
				,@strUnitMeasure
				)

		RETURN
	END

	IF @intItemId NOT IN (
			SELECT RI.intItemId
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			WHERE R.intItemId = @intProductId
				AND R.ysnActive = 1
				AND intRecipeItemTypeId = 1
				AND R.intLocationId = @intLocationId
			)
		and @intItemId NOT IN (
			SELECT RSI.intSubstituteItemId
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			JOIN dbo.tblMFRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
			WHERE R.intItemId = @intProductId
				AND R.ysnActive = 1
				AND RI.intRecipeItemTypeId = 1
				AND R.intLocationId = @intLocationId
			)
	BEGIN
		SELECT @strProductItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intProductId

		RAISERROR (
				51082
				,11
				,1
				,@strItemNo
				,@strLotNumber
				,@strProductItemNo
				)

		RETURN
	END

	SELECT @dblTotalQtyToBeConsumed = @dblQuantity * RI.dblCalculatedUpperTolerance / R.dblQuantity
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
	WHERE R.intItemId = @intProductId
		AND R.ysnActive = 1
		AND intRecipeItemTypeId = 1
		AND R.intLocationId = @intLocationId
		AND RI.intItemId = @intItemId

	IF @dblTotalQtyToBeConsumed IS NULL
	BEGIN
		SELECT @dblTotalQtyToBeConsumed = (@dblQuantity * RI.dblCalculatedUpperTolerance / R.dblQuantity) * RSI.dblSubstituteRatio
		FROM dbo.tblMFRecipe R
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
		JOIN dbo.tblMFRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
		WHERE R.intItemId = @intProductId
			AND R.ysnActive = 1
			AND RI.intRecipeItemTypeId = 1
			AND R.intLocationId = @intLocationId
			AND RI.intItemId = @intItemId
	END

	SELECT @dblQtyConsumedSoFar = SUM(WC.dblQuantity)
	FROM dbo.tblMFWorkOrderConsumedLot WC
	JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
		AND L.intItemId = @intItemId

	IF @dblQtyConsumedSoFar + @dblConsumeQty > @dblTotalQtyToBeConsumed
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		RAISERROR (
				51089
				,11
				,1
				,@dblConsumeQty
				,@strUnitMeasure
				,@strItemNo
				,@strLotNumber
				,@dblOnHand
				,@strUnitMeasure
				)

		RETURN
	END
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


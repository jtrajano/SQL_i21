CREATE PROCEDURE uspMFValidateWarehouseReleaseLot (
	@strLotNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
BEGIN TRY
	DECLARE @intLotId INT
		,@intLotStatusId INT
		,@strSecondaryStatus NVARCHAR(50)
		,@strPrimaryStatus NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@dblQty NUMERIC(38, 20)
		,@ErrMsg NVARCHAR(MAX)
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)
		,@intItemId int

	IF @strLotNumber = ''
		OR @strLotNumber IS NULL
	BEGIN
		RAISERROR (
				'Invalid Lot.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intLotId = intLotId
		,@dblQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@intItemId=intItemId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intLocationId = @intLocationId
		AND dblQty>0

	IF @intLotId IS NULL
	BEGIN
		RAISERROR (
				'Invalid Lot.'
				,11
				,1
				)

		RETURN
	END

	--IF NOT EXISTS (
	--		SELECT 1
	--		FROM dbo.tblMFWorkOrderProducedLot
	--		WHERE intLotId = @intLotId
	--		)
	--BEGIN
	--	RAISERROR (
	--			51054
	--			,11
	--			,1
	--			,@strLotNumber
	--			)

	--	RETURN
	--END

	IF @dblQty = 0
		OR EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE ysnReleased = 1
				AND intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				'Lot has already been released!.'
				,11
				,1
				)

		RETURN
	END

	SELECT @strSecondaryStatus = strSecondaryStatus
		,@strPrimaryStatus = strPrimaryStatus
	FROM dbo.tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF @intLotStatusId = 2
	BEGIN
		RAISERROR (
				'Pallet Lot has been marked as a ghost and cannot be released. Please call Supervisor to reverse this!.'
				,11
				,1
				)

		RETURN
	END

	IF @intLotStatusId = 1
		OR (
			@strSecondaryStatus = 'In_Warehouse'
			AND @strPrimaryStatus = 'On_Hold'
			)
		--OR (
		--	@strSecondaryStatus = 'ACTIVE'
		--	AND @strPrimaryStatus = 'ACTIVE'
		--	)
	BEGIN
		RAISERROR (
				'Lot has already been released!.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intManufacturingProcessId =intManufacturingProcessId
	FROM tblMFRecipe 
	WHERE intItemId=@intItemId AND intLocationId=@intLocationId AND ysnActive =1

	--IF NOT EXISTS (
	--		SELECT 1
	--		FROM dbo.tblMFRecipe R
	--		JOIN dbo.tblICLot L ON L.intItemId = R.intItemId
	--			AND R.intLocationId = @intLocationId
	--			AND R.intManufacturingProcessId = @intManufacturingProcessId
	--		)
	--BEGIN
	--	RAISERROR (
	--			51057
	--			,11
	--			,1
	--			)

	--	RETURN
	--END

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Warehouse Release Lot By Batch'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strAttributeValue = 'False' 
	BEGIN
		SELECT ISNULL(W.intWorkOrderId,0) AS intWorkOrderId
			,ISNULL(W.strWorkOrderNo,'') AS strWorkOrderNo
			,L.intLocationId
			,L.intParentLotId
			,PL.strParentLotNumber
			,L.intLotId
			,L.strLotNumber
			,I.strItemNo
			,I.strDescription
			,L.dblQty
			,IU.intItemUOMId
			,U.strUnitMeasure
			,U.intUnitMeasureId
			,R.intManufacturingProcessId
			,@strAttributeValue as strWarehouseReleaseLotByBatch
		FROM tblICLot L
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		JOIN dbo.tblMFRecipe R ON R.intItemId=I.intItemId AND R.intLocationId=@intLocationId AND R.ysnActive =1
		LEFT JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
		LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		WHERE L.intLotId = @intLotId
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
GO



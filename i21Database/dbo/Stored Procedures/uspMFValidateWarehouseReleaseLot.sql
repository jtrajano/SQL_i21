﻿CREATE PROCEDURE uspMFValidateWarehouseReleaseLot (
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
		,@dblQty NUMERIC(18, 6)
		,@ErrMsg NVARCHAR(MAX)
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)

	IF @strLotNumber = ''
		OR @strLotNumber IS NULL
	BEGIN
		RAISERROR (
				80020
				,11
				,1
				)

		RETURN
	END

	SELECT @intLotId = intLotId
		,@dblQty = dblQty
		,@intLotStatusId = intLotStatusId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intLocationId = @intLocationId

	IF @intLotId IS NULL
	BEGIN
		RAISERROR (
				80020
				,11
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				51054
				,11
				,1
				,@strLotNumber
				)

		RETURN
	END

	IF @dblQty = 0
		OR EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE ysnReleased = 1
				AND intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				51055
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
				51056
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
				51055
				,11
				,1
				)

		RETURN
	END

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrderProducedLot WPL
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
	WHERE WPL.intLotId = @intLotId

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblICLot L ON L.intItemId = R.intItemId
				AND R.intLocationId = @intLocationId
				AND R.intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		RAISERROR (
				51057
				,11
				,1
				)

		RETURN
	END

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
		SELECT W.intWorkOrderId
			,W.strWorkOrderNo
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
			,W.intManufacturingProcessId
			,@strAttributeValue as strWarehouseReleaseLotByBatch
		FROM tblICLot L
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
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



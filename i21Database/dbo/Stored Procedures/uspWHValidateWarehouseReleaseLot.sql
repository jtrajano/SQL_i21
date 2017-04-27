CREATE PROCEDURE uspWHValidateWarehouseReleaseLot 
	(@strLotNumber NVARCHAR(50), 
	 @intLocationId INT)
AS
BEGIN TRY
	DECLARE @intLotId INT, 
			@intLotStatusId INT, 
			@strSecondaryStatus NVARCHAR(50), 
			@strPrimaryStatus NVARCHAR(50), 
			@intManufacturingProcessId INT, 
			@dblQty NUMERIC(18, 6), 
			@ErrMsg NVARCHAR(MAX)
			,@intItemId int

	IF @strLotNumber = ''
		OR @strLotNumber IS NULL
	BEGIN
		RAISERROR ('Invalid Lot.', 11, 1)

		RETURN
	END

	SELECT @intLotId = intLotId, @dblQty = dblQty, @intLotStatusId = intLotStatusId, @intItemId=intItemId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intLocationId = @intLocationId
		AND dblQty>0

	IF @intLotId IS NULL
	BEGIN
		RAISERROR ('Invalid Lot.', 11, 1)

		RETURN
	END

	--IF NOT EXISTS (
	--		SELECT 1
	--		FROM dbo.tblMFWorkOrderProducedLot
	--		WHERE intLotId = @intLotId
	--		)
	--BEGIN
	--	RAISERROR ('This lot %s was not produced through work order production process; hence this lot cannot be released from this screen. Try changing the lot status using the Lot Status Change screen available in the Inventory view screen.', 11, 1, @strLotNumber)

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
		RAISERROR ('Lot has already been released!.', 11, 1)

		RETURN
	END

	SELECT @strSecondaryStatus = strSecondaryStatus, @strPrimaryStatus = strPrimaryStatus
	FROM dbo.tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF @intLotStatusId = 2
	BEGIN
		RAISERROR ('Pallet Lot has been marked as a ghost and cannot be released. Please call Supervisor to reverse this!.', 11, 1)

		RETURN
	END

	IF @intLotStatusId = 1
		OR (
			@strSecondaryStatus = 'In_Warehouse'
			AND @strPrimaryStatus = 'On_Hold'
			)
	BEGIN
		RAISERROR ('Lot has already been released!.', 11, 1)

		RETURN
	END

	SELECT @intManufacturingProcessId =intManufacturingProcessId
	FROM tblMFRecipe 
	WHERE intItemId=@intItemId AND intLocationId=@intLocationId AND ysnActive =1

	--SELECT @intManufacturingProcessId = intManufacturingProcessId
	--FROM tblMFWorkOrderProducedLot WPL
	--JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
	--WHERE WPL.intLotId = @intLotId

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblICLot L ON L.intItemId = R.intItemId
				AND R.intLocationId = @intLocationId
				AND R.intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		RAISERROR (51057, 11, 1)

		RETURN
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
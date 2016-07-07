CREATE PROCEDURE uspMFPickAlternateLotForKitting @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@strPickListNo NVARCHAR(50)
	,@intPickListDetailId INT
AS
BEGIN TRY
	DECLARE @strPickListLotNo NVARCHAR(50)
	DECLARE @intAlternateLotId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intPickListId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @dblAlternateLotQty NUMERIC(38, 20)
	DECLARE @dblReservedLotQtyForPickList NUMERIC(38, 20)
	DECLARE @dblAlternateLotReservedQty NUMERIC(38, 20)
	DECLARE @dblAlternateLotAvailableQty NUMERIC(38, 20)
	DECLARE @intTransactionCount INT
	DECLARE @strBlendProductionStagingLocation NVARCHAR(100)
	DECLARE @strKitStagingArea NVARCHAR(100)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intLotStatusId INT

	SELECT @intPickListId = intPickListId,
		   @intCompanyLocationId = intLocationId
	FROM tblMFPickList
	WHERE strPickListNo = @strPickListNo

	SELECT @dblReservedLotQtyForPickList = dblQuantity
	FROM tblMFPickListDetail
	WHERE intPickListDetailId = @intPickListDetailId

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation

	SELECT @intAlternateLotId = intLotId
		  ,@dblAlternateLotQty = dblWeight
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId

	SELECT @strBlendProductionStagingLocation = sl.strName
	FROM tblSMCompanyLocation cl
	JOIN tblICStorageLocation sl ON cl.intBlendProductionStagingUnitId = sl.intStorageLocationId
	WHERE intCompanyLocationId = 1

	SELECT @strKitStagingArea = sl.strName
	FROM tblMFAttribute a
	JOIN tblMFManufacturingProcessAttribute mpa ON mpa.intAttributeId = a.intAttributeId
	JOIN tblICStorageLocation sl ON sl.intStorageLocationId = mpa.strAttributeValue
	WHERE a.strAttributeName = 'Kit Staging Location'
		AND intManufacturingProcessId = 1
	
	IF (UPPER(@strLotSourceLocation) = UPPER(@strBlendProductionStagingLocation)) Or (UPPER(@strLotSourceLocation) = UPPER(@strKitStagingArea)) 
	BEGIN
		SET @strErrMsg= 'NOT ALLOWED TO PICK ANY LOT FROM THE LOCATION ''' + UPPER(@strLotSourceLocation) +'''.'
		RAISERROR(@strErrMsg,16,1)
	END

	IF ISNULL(@dblAlternateLotQty,0) <=0
	BEGIN
		SET @strErrMsg= 'QTY NOT AVAILABLE FOR LOT ' + @strAlternateLotNo +' ON LOCATION ' + @strLotSourceLocation +'.'
		RAISERROR(@strErrMsg,16,1)
	END	

	IF ISNULL(@intAlternateLotId,0) = 0
	BEGIN
		RAISERROR('ALTERNATE LOT DOES NOT EXISTS IN THE SCANNED LOCATION',16,1)
	END

	SELECT @intLotStatusId = intLotStatusId FROM tblICLot WHERE intLotId = @intAlternateLotId

	IF (@intLotStatusId <> 1)
	BEGIN
		RAISERROR('SCANNED LOT IS NOT ACTIVE. PLEASE SCAN AN ACTIVE LOT TO CONTINUE.',16,1)
	END

	IF EXISTS (
			SELECT 1
			FROM tblMFPickListDetail pld
			JOIN tblMFPickList pl ON pl.intPickListId = pld.intPickListId
			WHERE pld.intLotId = @intAlternateLotId
				AND pl.strPickListNo = @strPickListNo
				AND pld.intLotId <> @intLotId
			)
	BEGIN
		RAISERROR ('SCANNED LOT IS ALREADY AVAILABLE IN THE CURRENT PICK LIST.',16,1)
	END

	IF @intLotId <> @intAlternateLotId
	BEGIN
		SELECT @dblAlternateLotReservedQty = SUM(dblQty)
		FROM tblICStockReservation
		WHERE intLotId = @intAlternateLotId

		SET @dblAlternateLotAvailableQty = @dblAlternateLotQty - @dblAlternateLotReservedQty

		IF @dblAlternateLotAvailableQty < @dblReservedLotQtyForPickList
		BEGIN
			RAISERROR ('SUFFICIENT QTY IS NOT AVAILABLE FOR THE ALTERNATE LOT.',16,1)
		END
	END

	IF NOT EXISTS(SELECT PLD.intLotId, L.intItemId FROM tblMFPickList PL 
				  JOIN tblMFPickListDetail PLD ON PL.intPickListId = PLD.intPickListId
				  JOIN tblICLot L ON L.intLotId = PLD.intLotId
				  WHERE PL.strPickListNo = @strPickListNo AND L.strLotNumber = @strAlternateLotNo)
	BEGIN
		SET @strErrMsg= 'SCANNED ITEM IS NOT AVAILABLE IN THE PICKLIST.'
		RAISERROR(@strErrMsg,16,1)
	END

	BEGIN TRANSACTION

		IF EXISTS (SELECT 1 FROM tblMFPickListDetail WHERE intLotId = @intLotId AND intPickListId = @intPickListId)
		BEGIN
				UPDATE tblMFPickListDetail
				SET intLotId = @intAlternateLotId,
					intStorageLocationId = @intStorageLocationId
				WHERE intLotId = @intLotId
					AND intPickListId = @intPickListId
					AND intPickListDetailId = @intPickListDetailId

				UPDATE tblICStockReservation
				SET intLotId = @intAlternateLotId
				WHERE intLotId = @intLotId
					AND strTransactionId = @strPickListNo
		END
	COMMIT TRANSACTION

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @intTransactionCount = 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')

END CATCH
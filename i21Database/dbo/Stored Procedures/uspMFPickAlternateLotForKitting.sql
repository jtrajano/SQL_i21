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
	DECLARE @dblAlternateLotQty NUMERIC(38, 20)
	DECLARE @dblReservedLotQtyForPickList NUMERIC(38, 20)
	DECLARE @dblAlternateLotReservedQty NUMERIC(38, 20)
	DECLARE @dblAlternateLotAvailableQty NUMERIC(38, 20)
	DECLARE @intTransactionCount INT
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @intPickListId = intPickListId
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

	IF ISNULL(@dblAlternateLotQty,0) <=0
	BEGIN
		SET @strErrMsg= 'QTY NOT AVAILABLE FOR LOT ' + @strAlternateLotNo +' ON LOCATION ' + @strLotSourceLocation +'.'
		RAISERROR(@strErrMsg,16,1)
	END	

	IF ISNULL(@intAlternateLotId,0) = 0
	BEGIN
		RAISERROR('ALTERNATE LOT DOES NOT EXISTS IN THE SCANNED LOCATION',16,1)
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
		SELECT @dblAlternateLotReservedQty = dblQty
		FROM tblICStockReservation
		WHERE intLotId = @intAlternateLotId

		SET @dblAlternateLotAvailableQty = @dblAlternateLotQty - @dblAlternateLotReservedQty

		IF @dblAlternateLotAvailableQty < @dblReservedLotQtyForPickList
		BEGIN
			RAISERROR ('SUFFICIENT QTY IS NOT AVAILABLE FOR THE ALTERNATE LOT.',16,1)
		END
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
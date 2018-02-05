CREATE PROCEDURE uspMFLotReceiptPutaway (
	@strReceiptNumber NVARCHAR(50)
	,@strLotNumber NVARCHAR(50)
	,@strStorageLocationName NVARCHAR(50)
	)
AS
BEGIN TRY
	DECLARE @intInventoryReceiptId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intStorageLocationId INT

	SELECT @intInventoryReceiptId = intInventoryReceiptId
	FROM dbo.tblICInventoryReceipt
	WHERE strReceiptNumber = @strReceiptNumber

	SELECT @intStorageLocationId = intStorageLocationId
	FROM dbo.tblICStorageLocation
	WHERE strName = @strStorageLocationName

	UPDATE dbo.tblICInventoryReceiptItemLot
	SET intStorageLocationId = @intStorageLocationId
	FROM dbo.tblICInventoryReceiptItemLot IRL
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRL.intInventoryReceiptItemId
	WHERE IRL.strLotNumber = @strLotNumber
		AND IRI.intInventoryReceiptId = @intInventoryReceiptId
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
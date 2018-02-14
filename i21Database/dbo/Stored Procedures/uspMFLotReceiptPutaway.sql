CREATE PROCEDURE uspMFLotReceiptPutaway (
	@intInventoryReceiptItemLotId INT
	,@strStorageLocationName NVARCHAR(50)
	,@intLocationId INT
	,@intUserId INT
	)
AS
BEGIN TRY
	DECLARE @intInventoryReceiptId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intStorageLocationId INT
		,@intSubLocationId INT
		,@strSubLocationName NVARCHAR(50)

	SELECT @intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
	FROM dbo.tblICStorageLocation
	WHERE strName = @strStorageLocationName
		AND intLocationId = @intLocationId

	IF @intStorageLocationId IS NULL
	BEGIN
		RAISERROR (
				'INVALID LOCATION.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblICInventoryReceiptItemLot IRL
			JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRL.intInventoryReceiptItemId
			WHERE IRL.intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId
				AND IRI.intSubLocationId = @intSubLocationId
			)
	BEGIN
		SELECT @strSubLocationName = SL.strSubLocationName
		FROM dbo.tblICInventoryReceiptItemLot IRL
		JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRL.intInventoryReceiptItemId
		JOIN dbo.tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IRI.intSubLocationId
		WHERE IRL.intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId

		SET @ErrMsg = 'SCANNED LOCATION DOES NOT BELONG TO THE SUB LOCATION ''' + @strSubLocationName+''''

		RAISERROR (
				@ErrMsg
				,16
				,1
				)

		RETURN
	END

	UPDATE dbo.tblICInventoryReceiptItemLot
	SET intStorageLocationId = @intStorageLocationId
		,intConcurrencyId = intConcurrencyId + 1
	WHERE intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId
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

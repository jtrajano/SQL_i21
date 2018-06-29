CREATE PROCEDURE uspMFLotReceiptPutaway (
	@intInventoryReceiptItemLotId INT
	,@strStorageLocationName NVARCHAR(50)
	,@intLocationId INT
	,@intUserId INT
	,@strSubLocationName NVARCHAR(50) = ''
	)
AS
BEGIN TRY
	DECLARE @intInventoryReceiptId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intStorageLocationId INT
		,@intSubLocationId INT

	IF ISNULL(@strSubLocationName, '') <> ''
	BEGIN
		SELECT @intSubLocationId = CSL.intCompanyLocationSubLocationId
			,@intStorageLocationId = intStorageLocationId
		FROM tblSMCompanyLocationSubLocation CSL
		JOIN tblICStorageLocation SL ON SL.intSubLocationId = CSL.intCompanyLocationSubLocationId
			AND SL.strName = @strStorageLocationName
			AND SL.intLocationId = @intLocationId
			AND CSL.strSubLocationName = @strSubLocationName
	END
	ELSE
	BEGIN
		SELECT @intStorageLocationId = intStorageLocationId
			,@intSubLocationId = intSubLocationId
		FROM dbo.tblICStorageLocation
		WHERE strName = @strStorageLocationName
			AND intLocationId = @intLocationId
	END

	IF @intStorageLocationId IS NULL
		OR @intSubLocationId IS NULL
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

		SET @ErrMsg = 'SCANNED LOCATION DOES NOT BELONG TO THE IR SUB LOCATION ''' + @strSubLocationName + ''''

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

﻿CREATE PROCEDURE uspMFValidateLotByOrder (
	@strPickNo NVARCHAR(50)
	,@strScannedLotNo NVARCHAR(50)
	)
AS
BEGIN
	DECLARE @intStagingLocationId INT
		,@strName NVARCHAR(50)
		,@strErrMsg NVARCHAR(MAX) = ''

	SELECT @intStagingLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE strOrderNo = @strPickNo

	SELECT @strName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStagingLocationId

	IF NOT EXISTS (
			SELECT *
			FROM tblICLot
			WHERE strLotNumber = @strScannedLotNo
			)
	BEGIN
		RAISERROR (
				'INVALID LOT #.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblICLot
			WHERE strLotNumber = @strScannedLotNo
				AND dblQty > 0
			)
	BEGIN
		RAISERROR (
				'QUANTITY IS NOT AVAILABLE FOR THE SCANNED LOT.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblICLot
			WHERE strLotNumber = @strScannedLotNo
				AND intStorageLocationId = @intStagingLocationId
				AND dblQty > 0
			)
	BEGIN
		SELECT @strErrMsg = 'SCANNED LOT IS NOT AVAILABLE IN LOCATION ''' + @strName + '''.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)

		RETURN
	END
END

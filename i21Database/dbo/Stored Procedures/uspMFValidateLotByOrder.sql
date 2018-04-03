CREATE PROCEDURE uspMFValidateLotByOrder (
	@strPickNo NVARCHAR(50)
	,@strScannedLotNo NVARCHAR(50)
	,@intCompanyLocationId INT
	)
AS
BEGIN
	DECLARE @intStagingLocationId INT
		,@strName NVARCHAR(50)
		,@strErrMsg NVARCHAR(MAX) = ''
		,@intLotId int

	SELECT @intStagingLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE strOrderNo = @strPickNo
		AND intLocationId = @intCompanyLocationId

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
	SELECT @intLotId=intLotId
			FROM tblICLot
			WHERE strLotNumber = @strScannedLotNo
				AND intStorageLocationId = @intStagingLocationId
				AND dblQty > 0

	IF NOT EXISTS (Select *from tblMFTask Where intLotId=@intLotId and strTaskNo=@strPickNo and intTaskStateId=3
			
			)
	BEGIN
		SELECT @strErrMsg = 'SCANNED LOT IS NOT AVAILABLE IN THE SCANNED PICK LIST ''' + @strPickNo + '''.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)

		RETURN
	END
END

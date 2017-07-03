CREATE PROCEDURE uspMFUpdateTaskStatus (
	@strPickNo NVARCHAR(50)
	,@strLotNumber NVARCHAR(50)
	,@strDockDoorLocation NVARCHAR(50)
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intStagingLocationId INT
		,@strName NVARCHAR(50)

	SELECT @intStagingLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE strOrderNo = @strPickNo

	SELECT @strName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStagingLocationId
END

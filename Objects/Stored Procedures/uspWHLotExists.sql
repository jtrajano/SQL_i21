CREATE PROCEDURE uspWHLotExists @strLotNo NVARCHAR(30)
	,@intCompanyLocationId INT
AS
BEGIN
	DECLARE @intCount INT

	SET @intCount = 0

	SELECT @intCount = COUNT(1)
	FROM tblICLot
	WHERE strLotNumber = @strLotNo
		AND intLocationId = @intCompanyLocationId

	IF @intCount IS NULL
		SET @intCount = 0

	SELECT @intCount intLotCount
END

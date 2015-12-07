CREATE PROCEDURE uspWHGetLotIdByLotNo 
		@strLotNumber NVARCHAR(30), 
		@intStorageLocationId INT = 0
AS
BEGIN
	DECLARE @intLotId INT

	IF @intStorageLocationId = 0
	BEGIN
		SET @intLotId = (
				SELECT TOP 1 intLotId
				FROM dbo.tblICLot
				WHERE strLotNumber = @strLotNumber AND dblQty>0  
				)

		SELECT ISNULL(@intLotId, 0) intLotId, @strLotNumber strLotNo
	END
	ELSE
	BEGIN
		SET @intLotId = (
				SELECT TOP 1 intLotId
				FROM dbo.tblICLot
				WHERE strLotNumber = @strLotNumber
					AND intStorageLocationId= @intStorageLocationId AND dblQty>0  
				)

		SELECT ISNULL(@intLotId, 0) intLotId, @strLotNumber strLotNo
	END
END
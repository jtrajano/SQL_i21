CREATE PROCEDURE uspMFSetLotInformation 
						@intLotId INT
					   ,@strVendorLotNumber NVARCHAR(100)
					   ,@strLotAlias NVARCHAR(100)
AS
DECLARE @intParentLotId INT

BEGIN
	SELECT @intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

	UPDATE tblICLot
	SET strVendorLotNo = @strVendorLotNumber
		,strLotAlias = @strLotAlias
	WHERE intParentLotId = @intParentLotId
END
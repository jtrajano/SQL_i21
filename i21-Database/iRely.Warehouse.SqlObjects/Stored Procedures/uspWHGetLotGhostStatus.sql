CREATE PROCEDURE uspWHGetLotGhostStatus @strLotNumber NVARCHAR(30)
	,@intCompanyLocationId INT
AS
BEGIN
	SELECT l.strLotNumber
		,l.intLotId
		,ls.strSecondaryStatus
		,ls.strPrimaryStatus
	FROM tblICLot l
	JOIN tblICLotStatus AS ls ON ls.intLotStatusId = l.intLotStatusId
	WHERE l.strLotNumber = @strLotNumber
		AND l.intLocationId = @intCompanyLocationId
END

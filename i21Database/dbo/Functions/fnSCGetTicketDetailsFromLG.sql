CREATE FUNCTION [dbo].[fnSCGetTicketDetailsFromLG]
(
	@intLocationId INT = NULL,
	@intItemId INT = NULL
)
RETURNS @table TABLE
(
	intCompanyLocationSubLocationId INT NULL,
	intStorageLocationId INT NULL,
	intLotId INT NULL,
	strLotNumber VARCHAR(MAX)
)
AS 
BEGIN
	INSERT INTO @table(intCompanyLocationSubLocationId,intStorageLocationId,intLotId,strLotNumber)
	SELECT TOP 1 intCompanyLocationSubLocationId, intStorageLocationId, intLotId,strLotNumber FROM vyuSMCompanyLocationSubLocation  S
	LEFT JOIN vyuICGetStorageUnitByCategory U
		ON U.intSubLocationId = S.intCompanyLocationSubLocationId
	CROSS APPLY (SELECT * FROM (SELECT TOP 1 LGL.intLotId,strLotNumber FROM tblLGLoad L INNER JOIN tblLGLoadDetail LG ON LG.intLoadId = L.intLoadId INNER JOIN tblLGLoadDetailLot LGL ON LGL.intLoadDetailId = LG.intLoadDetailId INNER JOIN tblICLot LOT ON LOT.intLotId = LGL.intLotId WHERE LG.intItemId =  CASE WHEN @intItemId IS NULL THEN LG.intItemId ELSE @intItemId END) intLotId) Z
	WHERE S.intCompanyLocationId = @intLocationId

	RETURN 
END
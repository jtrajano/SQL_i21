DECLARE @intBookId INT, @intAssetId INT
DECLARE @tbl TABLE(
	intId INT IDENTITY(1,1),
	intBookId INT,
	intAssetId INT
)
DECLARE @intId INT

INSERT INTO @tbl
select 
B.intBookId,
A.intAssetId
from tblFABookDepreciation A JOIN tblFAFixedAssetDepreciation B ON 
B.intAssetId = A.intAssetId
AND A.intBookId = B.intBookId
WHERE strTransaction = 'Place in service'


WHILE EXISTS(SELECT 1 FROM @tbl)
BEGIN
	SELECT TOP 1 
		@intId = intId,
		@intAssetId = intAssetId,
		@intBookId = intBookId
	FROM @tbl

	IF NOT EXISTS( SELECT TOP 1 1 FROM tblFAFiscalAsset WHERE intAssetId = @intAssetId AND intBookId = @intBookId)
	BEGIN
		EXEC uspFAFiscalAsset @intAssetId, @intBookId
	END

	DELETE FROM @tbl WHERE @intId =intId
END


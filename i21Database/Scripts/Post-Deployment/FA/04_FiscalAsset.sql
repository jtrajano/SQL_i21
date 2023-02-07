DECLARE @intBookDepreciationId INT, @intAssetId INT
DECLARE @tbl TABLE(
	intId INT IDENTITY(1,1),
	intBookDepreciationId INT,
	intAssetId INT
)
DECLARE @intId INT

INSERT INTO @tbl
SELECT 
	B.intBookDepreciationId,
	A.intAssetId
FROM tblFABookDepreciation A 
LEFT JOIN tblFAFixedAssetDepreciation B ON B.intAssetId = A.intAssetId AND A.intBookDepreciationId = B.intBookDepreciationId
WHERE strTransaction = 'Place in service' OR strTransaction IS NULL

WHILE EXISTS(SELECT 1 FROM @tbl)
BEGIN
	SELECT TOP 1 
		@intId = intId,
		@intAssetId = intAssetId,
		@intBookDepreciationId = intBookDepreciationId
	FROM @tbl

	IF NOT EXISTS( SELECT TOP 1 1 FROM tblFAFiscalAsset WHERE intAssetId = @intAssetId AND intBookDepreciationId = @intBookDepreciationId)
	BEGIN
		EXEC uspFAFiscalAsset @intAssetId, @intBookDepreciationId
	END

	DELETE FROM @tbl WHERE @intId = intId
END


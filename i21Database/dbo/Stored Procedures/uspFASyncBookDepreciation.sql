CREATE PROCEDURE uspFASyncBookDepreciation
(
	@intAssetId INT
	
)
AS

DECLARE @intDepreciationMethodId INT = NULL
SELECT TOP 1 @intDepreciationMethodId = intDepreciationMethodId FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1

IF @intDepreciationMethodId IS NOT NULL
BEGIN
	UPDATE A SET 
	dblCost = B.dblCost
	, dblSalvageValue= B.dblSalvageValue
	, dtmPlacedInService= B.dtmDateInService
	FROM
	tblFABookDepreciation A JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId
	WHERE intDepreciationMethodId = @intDepreciationMethodId
END
ELSE
BEGIN
	INSERT INTO tblFABookDepreciation(intAssetId, intBookId, intDepreciationMethodId, dblCost, dblSalvageValue, dtmPlacedInService, intConcurrencyId)
	SELECT A.intAssetId, 1, @intDepreciationMethodId, A.dblCost, A.dblSalvageValue, A.dtmDateInService,1 FROM tblFAFixedAsset A
	WHERE @intAssetId = A.intAssetId

END

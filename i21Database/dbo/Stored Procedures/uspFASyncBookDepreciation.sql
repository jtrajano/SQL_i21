CREATE PROCEDURE uspFASyncBookDepreciation
(
	@intAssetId INT

)
AS

DECLARE @intBookDepreciationId INT = NULL
SELECT TOP 1 @intBookDepreciationId = intBookDepreciationId FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1

IF @intBookDepreciationId IS NOT NULL
BEGIN
	UPDATE A SET
	dblCost = B.dblCost
	, dblSalvageValue= B.dblSalvageValue
	, dtmPlacedInService= B.dtmDateInService
	FROM
	tblFABookDepreciation A JOIN tblFAFixedAsset B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE intBookDepreciationId = @intBookDepreciationId
END
ELSE
BEGIN
	DECLARE @intDepreciationMethodId INT
	SELECT TOP 1 @intDepreciationMethodId =A.intDepreciationMethodId FROM 
	tblFADepreciationMethod A
	JOIN tblFAFixedAsset FA ON FA.intDepreciationMethodId = A.intDepreciationMethodId
	LEFT JOIN tblFABookDepreciation B ON B.intDepreciationMethodId= A.intDepreciationMethodId
	WHERE FA.intAssetId = @intAssetId AND ISNULL(B.intBookId,1) = 1


	IF @intDepreciationMethodId IS NOT NULL
	INSERT INTO tblFABookDepreciation(intAssetId, intBookId, intDepreciationMethodId, dblCost, dblSalvageValue, dtmPlacedInService, intConcurrencyId)
	SELECT A.intAssetId, 1, @intDepreciationMethodId, A.dblCost, A.dblSalvageValue, A.dtmDateInService,1 FROM tblFAFixedAsset A
	WHERE @intAssetId = A.intAssetId

END

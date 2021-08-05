CREATE PROCEDURE uspFASyncBookDepreciation (  @intAssetId INT )  
AS  
DECLARE @intBookDepreciationId INT = NULL , @intDepreciationMethodId INT
SELECT TOP 1 @intBookDepreciationId = intBookDepreciationId FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1  
SELECT TOP 1 @intDepreciationMethodId = intDepreciationMethodId FROM tblFAFixedAsset where intAssetId = @intAssetId

IF @intDepreciationMethodId IS NULL
	DELETE FROM tblFABookDepreciation WHERE intAssetId= @intAssetId AND intBookId =1
ELSE
IF EXISTS(SELECT 1 FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1 )
BEGIN  
	UPDATE tblFABookDepreciation SET intDepreciationMethodId = @intDepreciationMethodId 
	WHERE intBookDepreciationId = @intBookDepreciationId

	UPDATE A 
	SET dblCost = B.dblCost , 
	dblSalvageValue= B.dblSalvageValue , 
	dtmPlacedInService= B.dtmDateInService  
	FROM tblFABookDepreciation A JOIN tblFAFixedAsset B 
	ON A.intAssetId = B.intAssetId
	WHERE intBookDepreciationId = @intBookDepreciationId
	AND intBookId = 1
	AND A.intAssetId = @intAssetId
END  
ELSE  
BEGIN  
	INSERT INTO tblFABookDepreciation(intAssetId, intBookId, intDepreciationMethodId, dblCost, dblSalvageValue, dtmPlacedInService, intConcurrencyId)  
	SELECT A.intAssetId, 1, @intDepreciationMethodId, A.dblCost, A.dblSalvageValue, A.dtmDateInService,1 FROM tblFAFixedAsset A  
	WHERE @intAssetId = A.intAssetId  
END

CREATE PROCEDURE uspFASyncBookDepreciation (  @intAssetId INT )  
AS  
DECLARE @intBookDepreciationId INT = NULL , @intDepreciationMethodId INT
SELECT TOP 1 @intBookDepreciationId = intBookDepreciationId FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1  
SELECT TOP 1 @intDepreciationMethodId = intDepreciationMethodId FROM tblFAFixedAsset where intAssetId = @intAssetId
  
IF EXISTS(SELECT 1 FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId =1 )
BEGIN  
	UPDATE tblFABookDepreciation SET intDepreciationMethodId = @intDepreciationMethodId WHERE intBookDepreciationId = @intBookDepreciationId
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
	INSERT INTO tblFABookDepreciation(intAssetId, intBookId, intDepreciationMethodId, dblCost, dblSalvageValue, dtmPlacedInService, intConcurrencyId)  
	SELECT A.intAssetId, 1, @intDepreciationMethodId, A.dblCost, A.dblSalvageValue, A.dtmDateInService,1 FROM tblFAFixedAsset A  
	WHERE @intAssetId = A.intAssetId  
END

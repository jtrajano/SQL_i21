CREATE PROCEDURE uspFACopyDepreciationMethod  
(  
    @intDepreciationMethodId INT,  
    @intAssetId INT,  
    @intBookId INT,
    @strName NVARCHAR(50)   
)  
AS  
BEGIN  
    DECLARE @intNewDepreciationMethodId INT   
	DECLARE @Id Id
    
	INSERT INTO @Id
	SELECT intDepreciationMethodId FROM tblFABookDepreciation WHERE intAssetId = @intAssetId and intBookId = @intBookId

	DELETE A FROM tblFABookDepreciation A JOIN @Id I ON A.intDepreciationMethodId = I.intId
	DELETE A FROM tblFADepreciationMethod A JOIN @Id I ON A.intDepreciationMethodId = I.intId
    
    INSERT INTO tblFADepreciationMethod(strDepreciationMethodId , strDepreciationType, intServiceYear, intMonth, dblSalvageValue,strConvention, dtmServiceDate, intConcurrencyId, intAssetId  )  
    SELECT @strName, strDepreciationType, intServiceYear, intMonth, dblSalvageValue,strConvention, dtmServiceDate,1, @intAssetId   
    FROM tblFADepreciationMethod WHERE @intDepreciationMethodId = intDepreciationMethodId  
    
    SELECT  @intNewDepreciationMethodId = SCOPE_IDENTITY()  
    
    INSERT INTO tblFADepreciationMethodDetail(intDepreciationMethodId, intYear, dblPercentage, intConcurrencyId)  
    SELECT @intNewDepreciationMethodId, intYear, dblPercentage, intConcurrencyId FROM tblFADepreciationMethodDetail 
    WHERE intDepreciationMethodId = @intDepreciationMethodId  

	INSERT INTO tblFABookDepreciation(intAssetId, intBookId, intDepreciationMethodId, dblCost, dblSalvageValue, dtmPlacedInService, intConcurrencyId)
	SELECT intAssetId, @intBookId, @intNewDepreciationMethodId, dblCost, dblSalvageValue, dtmDateInService,1 FROM tblFAFixedAsset WHERE @intAssetId = intAssetId
END


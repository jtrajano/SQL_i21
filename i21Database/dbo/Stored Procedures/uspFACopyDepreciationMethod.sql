CREATE PROCEDURE uspFACopyDepreciationMethod  
(  
    @intDepreciationMethodId INT,  
    @intAsssetId INT,  
    @strName NVARCHAR(50)   
)  
AS  
BEGIN  
    DECLARE @intNewDepreciationMethodId INT
    DELETE FROM tblFADepreciationMethod WHERE @intAsssetId = intAssetId

    INSERT INTO tblFADepreciationMethod(strDepreciationMethodId , strDepreciationType, intServiceYear, intMonth, dblSalvageValue,strConvention, dtmServiceDate, intConcurrencyId, intAssetId  )  
    SELECT @strName, strDepreciationType, intServiceYear, intMonth, dblSalvageValue,strConvention, dtmServiceDate,1, @intAsssetId   
    FROM tblFADepreciationMethod WHERE @intDepreciationMethodId = intDepreciationMethodId  
    
    SELECT  @intNewDepreciationMethodId = SCOPE_IDENTITY()  
    
    INSERT INTO tblFADepreciationMethodDetail(intDepreciationMethodId, intYear, dblPercentage, intConcurrencyId)  
    SELECT @intNewDepreciationMethodId, intYear, dblPercentage, intConcurrencyId FROM tblFADepreciationMethodDetail WHERE intDepreciationMethodId = @intDepreciationMethodId  
END
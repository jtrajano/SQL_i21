CREATE PROCEDURE uspFASyncBookDepreciation (  @intAssetId INT )  
AS  
DECLARE 
	@intBookDepreciationId INT = NULL, 
	@intDepreciationMethodId INT, 
	@rate NUMERIC(18, 6)

SELECT TOP 1 
	@intBookDepreciationId = intBookDepreciationId 
FROM tblFABookDepreciation 
WHERE intAssetId = @intAssetId AND intBookId = 1  

SELECT TOP 1 
	@intDepreciationMethodId = intDepreciationMethodId, 
	@rate = CASE WHEN ISNULL(dblForexRate, 0) > 0 THEN dblForexRate ELSE 1 END
FROM tblFAFixedAsset 
WHERE intAssetId = @intAssetId

IF @intDepreciationMethodId IS NULL
	DELETE FROM tblFABookDepreciation WHERE intAssetId= @intAssetId AND intBookId = 1
ELSE
IF EXISTS(SELECT 1 FROM tblFABookDepreciation WHERE intAssetId = @intAssetId AND intBookId = 1)
BEGIN  
	UPDATE tblFABookDepreciation SET intDepreciationMethodId = @intDepreciationMethodId 
	WHERE intBookDepreciationId = @intBookDepreciationId

	UPDATE A 
	SET 
		dblCost = B.dblCost , 
		dblSalvageValue= B.dblSalvageValue , 
		dtmPlacedInService= B.dtmDateInService,
		intCurrencyId = B.intCurrencyId,
		intFunctionalCurrencyId = B.intFunctionalCurrencyId,
		intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId,
		dblRate = @rate,
		dblFunctionalCost = B.dblCost * @rate,
		dblFunctionalSalvageValue =  B.dblSalvageValue * @rate,
		dblInsuranceValue = B.dblInsuranceValue,
		dblFunctionalInsuranceValue = B.dblInsuranceValue * @rate,
		dblMarketValue = B.dblMarketValue,
		dblFunctionalMarketValue = B.dblMarketValue * @rate
	FROM tblFABookDepreciation A 
	JOIN tblFAFixedAsset B 
		ON A.intAssetId = B.intAssetId
	WHERE 
		intBookDepreciationId = @intBookDepreciationId AND 
		intBookId = 1 AND 
		A.intAssetId = @intAssetId
END  
ELSE  
BEGIN  
	INSERT INTO tblFABookDepreciation(
		intAssetId, 
		intBookId, 
		intDepreciationMethodId, 
		dblCost, 
		dblSalvageValue,
		dtmPlacedInService,
		intCurrencyId,
		intFunctionalCurrencyId,
		intCurrencyExchangeRateTypeId,
		dblRate,
		dblFunctionalCost,
		dblFunctionalSalvageValue,
		dblInsuranceValue,
		dblFunctionalInsuranceValue,
		dblMarketValue,
		dblFunctionalMarketValue,
		intConcurrencyId)  
	SELECT 
		A.intAssetId, 
		1, 
		@intDepreciationMethodId, 
		A.dblCost, 
		A.dblSalvageValue, 
		A.dtmDateInService,
		A.intCurrencyId,
		A.intFunctionalCurrencyId,
		A.intCurrencyExchangeRateTypeId,
		@rate,
		A.dblCost * @rate,
		A.dblSalvageValue * @rate, 
		A.dblInsuranceValue,
		A.dblInsuranceValue * @rate,
		A.dblMarketValue,
		A.dblMarketValue * @rate,
		1 
	FROM tblFAFixedAsset A  
	WHERE @intAssetId = A.intAssetId  
END

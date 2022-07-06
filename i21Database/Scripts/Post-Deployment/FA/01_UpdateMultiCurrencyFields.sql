PRINT N'BEGIN Update tblFAFixedAsset Functional Currency and Forex Rate'

DECLARE @intFunctionalCurrencyId INT
SELECT TOP 1 @intFunctionalCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

UPDATE tblFAFixedAsset
SET
	dblForexRate = CASE WHEN ISNULL(dblForexRate, 0) > 0 THEN dblForexRate ELSE 1 END,
	dblFunctionalCost = ROUND((dblCost * (CASE WHEN ISNULL(dblForexRate, 0) > 0 THEN dblForexRate ELSE 1 END)), 2),
	dblFunctionalSalvageValue = ROUND((dblSalvageValue * (CASE WHEN ISNULL(dblForexRate, 0) > 0 THEN dblForexRate ELSE 1 END)), 2),
	intFunctionalCurrencyId = @intFunctionalCurrencyId
WHERE intFunctionalCurrencyId IS NULL

PRINT N'END Update tblFAFixedAsset Functional Currency and Forex Rate'

PRINT N'BEGIN Update tblFABookDepreciation Multi Currency fields'

UPDATE A 
SET 
	intCurrencyId = B.intCurrencyId,
	intFunctionalCurrencyId = B.intFunctionalCurrencyId,
	intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId,
	dblRate = B.dblForexRate,
	dblFunctionalCost = ROUND((A.dblCost * B.dblForexRate), 2),
	dblFunctionalSalvageValue = ROUND((A.dblSalvageValue * B.dblForexRate), 2),
	dblInsuranceValue = B.dblInsuranceValue,
	dblFunctionalInsuranceValue = ROUND((B.dblInsuranceValue * B.dblForexRate), 2),
	dblMarketValue = B.dblMarketValue,
	dblFunctionalMarketValue = ROUND((B.dblMarketValue * B.dblForexRate), 2),
	dblFunctionalBonusDepreciation = CASE WHEN ISNULL(A.dblBonusDepreciation, 0) > 0 THEN ROUND((A.dblBonusDepreciation * B.dblForexRate), 2) ELSE A.dblBonusDepreciation END,
	dblFunctionalSection179 = CASE WHEN ISNULL(A.dblSection179, 0) > 0 THEN ROUND((A.dblSection179 * B.dblForexRate), 2) ELSE A.dblSection179 END
FROM tblFABookDepreciation A 
JOIN tblFAFixedAsset B 
	ON A.intAssetId = B.intAssetId
WHERE 
	A.intFunctionalCurrencyId IS NULL

PRINT N'END Update tblFABookDepreciation Multi Currency fields'

PRINT N'BEGIN Update tblFAFixedAssetDepreciation Multi Currency fields'

UPDATE FAD
SET 
	dblRate = BD.dblRate,
	dblFunctionalBasis = ROUND((FAD.dblBasis * BD.dblRate), 2),
	dblFunctionalDepreciationToDate = ROUND((FAD.dblDepreciationToDate * BD.dblRate), 2),
	dblFunctionalSalvageValue = ROUND((FAD.dblSalvageValue * BD.dblRate) , 2)
FROM tblFAFixedAssetDepreciation FAD
JOIN tblFABookDepreciation BD ON BD.intAssetId = FAD.intAssetId AND BD.intBookId = FAD.intBookId
WHERE 
	FAD.dblFunctionalDepreciationToDate = 0 OR FAD.dblFunctionalBasis = 0

PRINT N'END Update tblFAFixedAssetDepreciation Multi Currency fields'

CREATE VIEW vyuFAFixedAssetHistory
AS
WITH FA AS (
	SELECT 
		dtmDateInService
		,dblForexRate
		,intAssetId
		,strAssetId
		,intDepreciationMethodId
		,dblCost
		,dblSalvageValue
		,dtmCreateAssetPostDate
		,ysnImported
	FROM tblFAFixedAsset
	--GROUP BY intAssetId, strAssetId, dtmDateInService, intDepreciationMethodId, dblForexRate, dblCost, dblSalvageValue
),
G AS(
	SELECT 
		dtmDepreciationToDate
		,intAssetId
		,strTransaction
	FROM tblFAFixedAssetDepreciation 
	GROUP BY dtmDepreciationToDate,intAssetId,strTransaction
)
SELECT
	dtmDepreciationToDate = CASE WHEN ISNULL(FA.ysnImported, 0) = 1 AND FA.dtmCreateAssetPostDate IS NOT NULL THEN FA.dtmCreateAssetPostDate ELSE FA.dtmDateInService END,
	0 dblDepreciationToDate,
	0 dblFunctionalDepreciationToDate,
	0 dblDepreciation,
	0 dblFunctionalDepreciation,
	FA.dblForexRate dblRate,
	0 dblTaxDepreciationToDate,
	0 dblFunctionalTaxDepreciationToDate,
	0 dblTaxDepreciation,
	0 dblFunctionalTaxDepreciation,
	0 dblTaxRate,
	FA.intAssetId,
	1 intAssetDepreciationId,
	DM.intDepreciationMethodId, 
	DM.strDepreciationMethodId, 
	GL.strTransactionType strTransaction, 
	GL.strTransactionId, 
	(FA.dblCost - FA.dblSalvageValue) dblBasis,
	(FA.dblCost - FA.dblSalvageValue) dblDepreciationBasis,
	ROUND((FA.dblCost - FA.dblSalvageValue) * ISNULL(FA.dblForexRate, 1), 2) dblFunctionalBasis,
	ROUND((FA.dblCost - FA.dblSalvageValue) * ISNULL(FA.dblForexRate, 1), 2) dblFunctionalDepreciationBasis,
	DM.strDepreciationType strType,
	DM.strConvention, 
	FA.dtmDateInService, 
	NULL dtmDispositionDate, 
	FA.dblSalvageValue,
	ROUND((FA.dblSalvageValue * ISNULL(FA.dblForexRate, 1)), 2) dblFunctionalSalvageValue,
	0 dblSection179,
	0 dblFunctionalSection179,
	0 dblBonusDepreciation,
	0 dblFunctionalBonusDepreciation,
	1 intConcurrencyId
 FROM FA
 LEFT JOIN tblGLDetail GL ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
 LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = FA.intDepreciationMethodId
 WHERE GL.strTransactionType = 'Purchase' AND GL.ysnIsUnposted = 0
 GROUP BY 
	FA.intAssetId, 
	FA.dtmCreateAssetPostDate,
	FA.ysnImported,
	GL.strTransactionType, 
	GL.strTransactionId, 
	FA.dblCost,
	FA.dblSalvageValue, 
	FA.dblForexRate,
	DM.strDepreciationMethodId, 
	DM.strConvention, 
	FA.dtmDateInService, 
	FA.dblSalvageValue,
	DM.intDepreciationMethodId,
	DM.strDepreciationType,
	GL.dtmTransactionDate
UNION ALL
SELECT 
	G.dtmDepreciationToDate, 
	ISNULL(GAAP.dblDepreciationToDate, 0) dblDepreciationToDate,
	ISNULL(GAAP.dblFunctionalDepreciationToDate, 0) dblFunctionalDepreciationToDate,
	ISNULL(GAAP.dblDepreciation, 0) dblDepreciation,
	ISNULL(GAAP.dblFunctionalDepreciation, 0) dblFunctionalDepreciation,
	ISNULL(GAAP.dblRate, 1) dblRate,
	CASE WHEN G.strTransaction NOT IN ('Basis Adjustment', 'Depreciation Adjustment') 
		THEN ISNULL(Tax.dblDepreciationToDate, 
			CASE WHEN FullyDepreciatedTax.dtmDepreciationToDate <= G.dtmDepreciationToDate
				THEN FullyDepreciatedTax.dblDepreciationToDate ELSE 0 END) 
		ELSE ISNULL(Tax.dblDepreciationToDate, 0) END dblTaxDepreciationToDate,
	CASE WHEN G.strTransaction NOT IN ('Basis Adjustment', 'Depreciation Adjustment') 
		THEN ISNULL(Tax.dblFunctionalDepreciationToDate, 
			CASE WHEN FullyDepreciatedTax.dtmDepreciationToDate <= G.dtmDepreciationToDate
				THEN FullyDepreciatedTax.dblFunctionalDepreciationToDate ELSE 0 END) 
		ELSE ISNULL(Tax.dblFunctionalDepreciationToDate, 0) END dblFunctionalTaxDepreciationToDate,
	ISNULL(Tax.dblDepreciation, 0) dblTaxDepreciation,
	ISNULL(Tax.dblFunctionalDepreciation, 0) dblFunctionalTaxDepreciation,
	ISNULL(Tax.dblRate, 0) dblTaxRate,
	G.intAssetId,
	ISNULL(GAAP.intAssetDepreciationId,Tax.intAssetDepreciationId) intAssetDepreciationId,
	ISNULL(GAAP.intDepreciationMethodId, Tax.intDepreciationMethodId) intDepreciationMethodId,
	ISNULL(GAAP.strDepreciationMethodId, Tax.strDepreciationMethodId) strDepreciationMethodId,
	ISNULL(GAAP.strTransaction, Tax.strTransaction) strTransaction,
	ISNULL(GAAP.strTransactionId, Tax.strTransactionId) strTransactionId,
	ISNULL(GAAP.dblBasis,Tax.dblBasis) dblBasis,
	ISNULL(GAAP.dblDepreciationBasis,Tax.dblDepreciationBasis) dblDepreciationBasis,
	ISNULL(GAAP.dblFunctionalBasis,Tax.dblFunctionalBasis) dblFunctionalBasis,
	ISNULL(GAAP.dblFunctionalDepreciationBasis,Tax.dblFunctionalDepreciationBasis) dblFunctionalDepreciationBasis,
	ISNULL(GAAP.strType, Tax.strType)strType,
	ISNULL(GAAP.strConvention, Tax.strConvention)strConvention,
	ISNULL(GAAP.dtmDateInService, Tax.dtmDateInService)dtmDateInService,
	ISNULL(GAAP.dtmDispositionDate,Tax.dtmDispositionDate)dtmDispositionDate,
	ISNULL(GAAP.dblSalvageValue, Tax.dblSalvageValue)dblSalvageValue,
	ISNULL(GAAP.dblFunctionalSalvageValue, Tax.dblFunctionalSalvageValue)dblFunctionalSalvageValue,
	CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = G.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblSection179, 0) ELSE 0 END dblSection179,
	CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = G.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblFunctionalSection179, 0) ELSE 0 END dblFunctionalSection179,
	CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = G.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblBonusDepreciation, 0) ELSE 0 END dblBonusDepreciation,
	CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = G.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblFunctionalBonusDepreciation, 0) ELSE 0 END dblFunctionalBonusDepreciation,
	ISNULL(GAAP.intConcurrencyId, Tax.intConcurrencyId) intConcurrencyId
FROM G 
outer apply(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	dblFunctionalDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	dblDepreciationBasis,
	dblFunctionalBasis,
	dblFunctionalDepreciationBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.dblFunctionalSalvageValue,
	dblRate,
	dblDepreciation,
	dblFunctionalDepreciation,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B ON A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND intBookId = 1
	AND A.strTransaction = G.strTransaction
)GAAP
OUTER APPLY(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	dblFunctionalDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	dblDepreciationBasis,
	dblFunctionalBasis,
	dblFunctionalDepreciationBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.dblFunctionalSalvageValue,
	A.dblRate,
	dblDepreciation,
	dblFunctionalDepreciation,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND A.intBookId = 2
	AND A.strTransaction = G.strTransaction
)Tax
OUTER APPLY (
	SELECT TOP 1 FAD.dblDepreciationToDate, FAD.intAssetDepreciationId, FAD.dblFunctionalDepreciationToDate, FAD.dtmDepreciationToDate
	FROM tblFAFixedAssetDepreciation FAD
	JOIN tblFABookDepreciation BD ON BD.intAssetId = FAD.intAssetId AND BD.intBookId = FAD.intBookId
	WHERE FAD.intAssetId = G.intAssetId AND FAD.intBookId = 2 AND BD.intBookId = 2 AND FAD.strTransaction = 'Depreciation' AND BD.ysnFullyDepreciated = 1
	ORDER BY FAD.dtmDepreciationToDate DESC
) FullyDepreciatedTax

OUTER APPLY (
	SELECT TOP 1 BD.dblSection179, BD.dblFunctionalSection179, BD.dblBonusDepreciation, BD.dblFunctionalBonusDepreciation, dtmDepreciationToDate
	FROM tblFABookDepreciation BD 
	LEFT JOIN tblFAFixedAssetDepreciation A on A.intAssetId = BD.intAssetId AND A.intBookId = 2
	WHERE BD.intAssetId = G.intAssetId
	AND BD.intBookId = 2
	AND A.strTransaction = G.strTransaction
	AND A.strTransaction = 'Depreciation'
	ORDER BY dtmDepreciationToDate
) TaxFirstDepreciation
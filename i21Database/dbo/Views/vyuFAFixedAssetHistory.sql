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
	FROM tblFAFixedAsset
	GROUP BY intAssetId, strAssetId, dtmDateInService, intDepreciationMethodId, dblForexRate, dblCost, dblSalvageValue
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
	1 intAssetDepreciationId,
	FA.intAssetId,
	FA.dtmDateInService dtmDepreciationToDate,
	DM.intDepreciationMethodId, 
	DM.strDepreciationMethodId, 
	(FA.dblCost - FA.dblSalvageValue) dblBasis,
	FA.dtmDateInService, 
	NULL dtmDispositionDate, 
	0 dblDepreciationToDate,
	0 dblTaxDepreciationToDate,
	FA.dblSalvageValue,
	GL.strTransactionType strTransaction, 
	GL.strTransactionId, 
	DM.strDepreciationType strType,
	DM.strConvention, 
	1 intConcurrencyId
 FROM FA
 LEFT JOIN tblGLDetail GL ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
 LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = FA.intDepreciationMethodId
 WHERE GL.strTransactionType = 'Purchase' AND GL.ysnIsUnposted = 0
 GROUP BY 
	FA.intAssetId, 
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
	ISNULL(GAAP.intAssetDepreciationId,Tax.intAssetDepreciationId) intAssetDepreciationId,
	G.intAssetId,
	G.dtmDepreciationToDate, 
	ISNULL(GAAP.intDepreciationMethodId, Tax.intDepreciationMethodId) intDepreciationMethodId,
	ISNULL(GAAP.strDepreciationMethodId, Tax.strDepreciationMethodId) strDepreciationMethodId,
	ISNULL(GAAP.dblBasis,Tax.dblBasis) dblBasis,
	ISNULL(GAAP.dtmDateInService, Tax.dtmDateInService)dtmDateInService,
	ISNULL(GAAP.dtmDispositionDate,Tax.dtmDispositionDate)dtmDispositionDate,
	ISNULL(GAAP.dblDepreciationToDate, 0) dblDepreciationToDate,
	ISNULL(Tax.dblDepreciationToDate, 0) dblTaxDepreciationToDate,
	ISNULL(GAAP.dblSalvageValue, Tax.dblSalvageValue) dblSalvageValue,
	ISNULL(GAAP.strTransaction, Tax.strTransaction) strTransaction,
	ISNULL(GAAP.strTransactionId, Tax.strTransactionId) strTransactionId,
	ISNULL(GAAP.strType, Tax.strType)strType,
	ISNULL(GAAP.strConvention, Tax.strConvention)strConvention,
	ISNULL(GAAP.intConcurrencyId, Tax.intConcurrencyId) intConcurrencyId
FROM G 
outer apply(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
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
	strTransaction,
	strTransactionId,
	dblBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND A.intBookId = 2
	AND A.strTransaction = G.strTransaction
)Tax
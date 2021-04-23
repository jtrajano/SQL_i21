CREATE VIEW vyuFAFixedAssetHistory
AS

WITH G AS(
SELECT dtmDepreciationToDate, intAssetId
FROM tblFAFixedAssetDepreciation
GROUP BY dtmDepreciationToDate,intAssetId
)

SELECT G.dtmDepreciationToDate, GAAP.dblDepreciationToDate , Tax.dblDepreciationToDate dblTaxDepreciationToDate, G.intAssetId,
ISNULL(GAAP.intAssetDepreciationId,Tax.intAssetDepreciationId) intAssetDepreciationId,
ISNULL(GAAP.intDepreciationMethodId, Tax.intDepreciationMethodId) intDepreciationMethodId,
ISNULL(GAAP.strDepreciationMethodId, Tax.strDepreciationMethodId) strDepreciationMethodId,
ISNULL(GAAP.strTransaction, Tax.strTransaction) strTransaction,
ISNULL(GAAP.strTransactionId, Tax.strTransactionId) strTransactionId,
ISNULL(GAAP.dblBasis,Tax.dblBasis)dblBasis,
ISNULL(GAAP.strType, Tax.strType)strType,
ISNULL(GAAP.strConvention, Tax.strConvention)strConvention,
ISNULL(GAAP.dtmDateInService, Tax.dtmDateInService)dtmDateInService,
ISNULL(GAAP.dtmDispositionDate,Tax.dtmDispositionDate)dtmDispositionDate,
ISNULL(GAAP.dblSalvageValue, Tax.dblSalvageValue)dblSalvageValue,
ISNULL(GAAP.intConcurrencyId, Tax.intConcurrencyId)intConcurrencyId

from G
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
	left join tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId

	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate and A.intAssetId = G.intAssetId

	and intBookId = 1
)GAAP
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
	left join tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate and A.intAssetId = G.intAssetId
	AND intBookId = 2
)Tax
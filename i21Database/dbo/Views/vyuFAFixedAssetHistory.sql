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
		,intFunctionalCurrencyId
	FROM tblFAFixedAsset
)
SELECT
	  dtmDepreciationToDate = CASE WHEN ISNULL(FA.ysnImported, 0) = 1 AND FA.dtmCreateAssetPostDate IS NOT NULL THEN FA.dtmCreateAssetPostDate ELSE FA.dtmDateInService END
	, dblDepreciationToDate = 0
	, dblFunctionalDepreciationToDate = 0
	, dblDepreciation = 0
	, dblFunctionalDepreciation = 0
	, dblRate = FA.dblForexRate
	, intAssetId = FA.intAssetId
	, intAssetDepreciationId = 1
	, intDepreciationMethodId = DM.intDepreciationMethodId
	, strDepreciationMethodId = DM.strDepreciationMethodId
	, strTransaction = GL.strTransactionType
	, strTransactionId = GL.strTransactionId
	, dblBasis = (FA.dblCost - FA.dblSalvageValue)
	, dblDepreciationBasis = (FA.dblCost - FA.dblSalvageValue)
	, dblFunctionalBasis = ROUND((FA.dblCost - FA.dblSalvageValue) * ISNULL(FA.dblForexRate, 1), 2)
	, dblFunctionalDepreciationBasis = ROUND((FA.dblCost - FA.dblSalvageValue) * ISNULL(FA.dblForexRate, 1), 2)
	, strType = DM.strDepreciationType
	, strConvention = DM.strConvention
	, dtmDateInService = FA.dtmDateInService
	, dtmDispositionDate = NULL
	, dblSalvageValue = FA.dblSalvageValue
	, dblFunctionalSalvageValue = ROUND((FA.dblSalvageValue * ISNULL(FA.dblForexRate, 1)), 2)
	, dblSection179 = 0
	, dblFunctionalSection179 = 0
	, dblBonusDepreciation = 0
	, dblFunctionalBonusDepreciation = 0
	, ysnAddToBasis = CAST(0 AS BIT)
	, strCurrencyForeign = Currency.strCurrency
	, strFunctionalCurrency = CurrencyFN.strCurrency
	, strLedgerName = NULL
	, intBookDepreciationId = 0
	, intConcurrencyId = 1
FROM FA
LEFT JOIN tblGLDetail GL ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = FA.intDepreciationMethodId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = GL.intCurrencyId
LEFT JOIN tblSMCurrency CurrencyFN ON CurrencyFN.intCurrencyID = FA.intFunctionalCurrencyId
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
	GL.dtmTransactionDate,
	Currency.strCurrency,
	CurrencyFN.strCurrency
UNION ALL
SELECT
	  dtmDepreciationToDate = FAD.dtmDepreciationToDate
	, dblDepreciationToDate = FAD.dblDepreciationToDate
	, dblFunctionalDepreciationToDate = FAD.dblFunctionalDepreciationToDate
	, dblDepreciation = FAD.dblDepreciation
	, dblFunctionalDepreciation = FAD.dblFunctionalDepreciation
	, dblRate = FAD.dblRate
	, intAssetId = FAD.intAssetId
	, intAssetDepreciationId = FAD.intAssetDepreciationId
	, intDepreciationMethodId = DM.intDepreciationMethodId
	, strDepreciationMethodId = DM.strDepreciationMethodId
	, strTransaction = FAD.strTransaction
	, strTransactionId = FAD.strTransactionId
	, dblBasis = FAD.dblBasis
	, dblDepreciationBasis = FAD.dblDepreciationBasis
	, dblFunctionalBasis = FAD.dblFunctionalBasis
	, dblFunctionalDepreciationBasis = FAD.dblFunctionalDepreciationBasis
	, strType = DM.strDepreciationType
	, strConvention = DM.strConvention
	, dtmDateInService = FAD.dtmDateInService
	, dtmDispositionDate = FAD.dtmDispositionDate
	, dblSalvageValue = FAD.dblSalvageValue
	, dblFunctionalSalvageValue = FAD.dblFunctionalSalvageValue
	, dblSection179 =					CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = FAD.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblSection179, 0) ELSE 0 END
	, dblFunctionalSection179 =			CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = FAD.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblFunctionalSection179, 0) ELSE 0 END
	, dblBonusDepreciation =			CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = FAD.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblBonusDepreciation, 0) ELSE 0 END
	, dblFunctionalBonusDepreciation =	CASE WHEN TaxFirstDepreciation.dtmDepreciationToDate = FAD.dtmDepreciationToDate THEN ISNULL(TaxFirstDepreciation.dblFunctionalBonusDepreciation, 0) ELSE 0 END
	, ysnAddToBasis = CAST(FAD.ysnAddToBasis AS BIT)
	, strCurrencyForeign = Currency.strCurrency
	, strFunctionalCurrency = CurrencyFN.strCurrency
	, strLedgerName = L.strLedgerName
	, intBookDepreciationId = BD.intBookDepreciationId
	, intConcurrencyId = 1
FROM tblFAFixedAssetDepreciation FAD
JOIN tblFABookDepreciation BD ON BD.intAssetId = FAD.intAssetId AND BD.intBookDepreciationId = FAD.intBookDepreciationId
LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = FAD.intCurrencyId
LEFT JOIN tblSMCurrency CurrencyFN ON CurrencyFN.intCurrencyID = FAD.intFunctionalCurrencyId
OUTER APPLY (
	SELECT TOP 1 B.dblSection179, B.dblFunctionalSection179, B.dblBonusDepreciation, B.dblFunctionalBonusDepreciation, dtmDepreciationToDate
	FROM tblFABookDepreciation B
	JOIN tblFAFixedAssetDepreciation A ON A.intAssetId = B.intAssetId AND A.intBookDepreciationId = B.intBookDepreciationId
	WHERE B.intAssetId = FAD.intAssetId
	AND B.intBookId <> 1
	AND A.strTransaction = 'Depreciation'
	AND B.intBookDepreciationId = FAD.intBookDepreciationId
	ORDER BY dtmDepreciationToDate
) TaxFirstDepreciation
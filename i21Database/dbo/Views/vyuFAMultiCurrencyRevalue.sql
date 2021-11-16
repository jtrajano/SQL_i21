CREATE VIEW [dbo].[vyuFAMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Asset' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	FA.strAssetId COLLATE Latin1_General_CI_AS,
	strTransactionDate		=	FA.dtmDateInService,
	strTransactionDueDate	=	NULL,
	strVendorName			=	'' COLLATE Latin1_General_CI_AS,
	strCommodity			=	'' COLLATE Latin1_General_CI_AS,
	strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS,
	strLocation				=	Company.strLocationName COLLATE Latin1_General_CI_AS,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	'' COLLATE Latin1_General_CI_AS,
	strItemId				=	'' COLLATE Latin1_General_CI_AS,
	dblQuantity				=	NULL,
	dblUnitPrice			=	NULL,
	dblAmount    			=   CASE WHEN BD.ysnFullyDepreciated = 1
									THEN FA.dblCost - ISNULL(FA.dblSalvageValue, 0)
									ELSE FA.dblCost - ISNULL(AccumulatedDepreciation.dblAmountForeign, 0) END,-- Asset's net value
	intCurrencyId			=	FA.intCurrencyId,
	intForexRateType		=	RateType.intCurrencyExchangeRateTypeId,
	strForexRateType		=	RateType.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS,
	dblForexRate			=	FA.dblForexRate,
	dblHistoricAmount		=	CASE WHEN BD.ysnFullyDepreciated = 1
									THEN (FA.dblCost - ISNULL(FA.dblSalvageValue, 0)) * FA.dblForexRate
									ELSE (FA.dblCost - ISNULL(AccumulatedDepreciation.dblAmountForeign, 0)) * FA.dblForexRate END,
	dblNewForexRate         =   0, --Calcuate By GL
    dblNewAmount            =   0, --Calcuate By GL
    dblUnrealizedDebitGain  =   0, --Calcuate By GL
    dblUnrealizedCreditGain =   0, --Calcuate By GL
    dblDebit                =   0, --Calcuate By GL
    dblCredit               =   0  --Calcuate By GL
FROM tblFAFixedAsset FA
JOIN tblFABookDepreciation BD
	ON BD.intAssetId = FA.intAssetId
LEFT JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = FA.intCompanyLocationId
LEFT JOIN tblSMCurrencyExchangeRateType RateType 
	ON RateType.intCurrencyExchangeRateTypeId = FA.intCurrencyExchangeRateTypeId
LEFT JOIN tblSMCompanyLocation Company 
	ON Company.intCompanyLocationId = FA.intCompanyLocationId   
OUTER APPLY (
	SELECT 
		SUM(dblCredit - dblDebit) dblAmount,
		SUM(dblCreditForeign - dblDebitForeign) dblAmountForeign
	FROM tblGLDetail GL
	WHERE 
		GL.intAccountId = FA.intAccumulatedAccountId
		AND strCode = 'AMDPR'
		AND ysnIsUnposted = 0
		AND GL.strReference = FA.strAssetId
	GROUP BY GL.strReference
) AccumulatedDepreciation
WHERE 
	FA.ysnDepreciated = 1
	AND FA.ysnDisposed = 0
	AND BD.intBookId = 1
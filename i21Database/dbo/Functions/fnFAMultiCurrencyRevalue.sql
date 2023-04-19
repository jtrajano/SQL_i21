CREATE FUNCTION [dbo].[fnFAMultiCurrencyRevalue]
(
	@dtmDate DATETIME
)
RETURNS @tbl TABLE  (
	strTransactionType NVARCHAR(100),
	strTransactionId NVARCHAR(40),
	strTransactionDate NVARCHAR(50),
	strTransactionDueDate NVARCHAR(50),
	strVendorName NVARCHAR(255),
	strCommodity NVARCHAR(50),
	strLineOfBusiness NVARCHAR(50),
	strLocation NVARCHAR(50),
	strTicket NVARCHAR(40),
	strContractNumber NVARCHAR(40),
	strItemId NVARCHAR(40),
	dblQuantity NUMERIC(18, 6) NULL,
	dblUnitPrice NUMERIC(18, 6) NULL,
	dblAmount NUMERIC(18, 6),
	intCurrencyId INT NULL,
	intForexRateType INT NULL,
	strForexRateType NVARCHAR (100),
	dblForexRate NUMERIC(18, 6) NULL,
	dblHistoricAmount NUMERIC (18, 6) NULL,
	dblNewForexRate NUMERIC(18, 6),
	dblNewAmount NUMERIC(18,6),
	dblUnrealizedDebitGain NUMERIC (18, 6),
	dblUnrealizedCreditGain NUMERIC (18, 6),
	dblDebit NUMERIC (18, 6),
	dblCredit NUMERIC (18, 6),
	intCompanyLocationId INT NULL,
	intAccountId INT NULL
)
AS
BEGIN
	INSERT INTO @tbl
	SELECT DISTINCT
		strTransactionType		=	'Asset' COLLATE Latin1_General_CI_AS,
		strTransactionId		=	FA.strAssetId COLLATE Latin1_General_CI_AS,
		strTransactionDate		=	AccumulatedDepreciation.dtmDate,
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
										THEN ISNULL(Adjustment.dblAdjustment, 0) + FA.dblCost - ISNULL(FA.dblSalvageValue, 0)
										ELSE ISNULL(Adjustment.dblAdjustment, 0) + FA.dblCost - ISNULL(FA.dblSalvageValue, 0) - ISNULL(AccumulatedDepreciation.dblAmountForeign, 0) END,-- Asset's net value
		intCurrencyId			=	FA.intCurrencyId,
		intForexRateType		=	RateType.intCurrencyExchangeRateTypeId,
		strForexRateType		=	RateType.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS,
		dblForexRate			=	FA.dblForexRate,
		dblHistoricAmount		=	CASE WHEN BD.ysnFullyDepreciated = 1
										THEN (ISNULL(Adjustment.dblAdjustment, 0) + FA.dblCost - ISNULL(FA.dblSalvageValue, 0)) * FA.dblForexRate
										ELSE (ISNULL(Adjustment.dblAdjustment, 0) + FA.dblCost - ISNULL(FA.dblSalvageValue, 0) - ISNULL(AccumulatedDepreciation.dblAmountForeign, 0)) * FA.dblForexRate END,
		dblNewForexRate         =   0, --Calcuate By GL
		dblNewAmount            =   0, --Calcuate By GL
		dblUnrealizedDebitGain  =   0, --Calcuate By GL
		dblUnrealizedCreditGain =   0, --Calcuate By GL
		dblDebit                =   0, --Calcuate By GL
		dblCredit               =   0, --Calcuate By GL
		intCompanyLocationId	=	CL.intCompanyLocationId,
		intAccountId			=	FA.intAssetAccountId
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
			SUM(dblCreditForeign - dblDebitForeign) dblAmountForeign,
			MAX(dtmDate) dtmDate
		FROM tblGLDetail GL
		WHERE 
			GL.intAccountId = FA.intAccumulatedAccountId
			AND strCode = 'AMDPR'
			AND ysnIsUnposted = 0
			AND GL.strReference = FA.strAssetId
			AND GL.dtmDate <= @dtmDate
		GROUP BY GL.strReference
	) AccumulatedDepreciation
	OUTER APPLY (
		SELECT SUM(ISNULL(B.dblAdjustment, 0)) dblAdjustment
		FROM tblFABasisAdjustment B
		WHERE B.strAdjustmentType = 'Basis' 
			AND B.intBookId = 1
			AND B.dtmDate <= @dtmDate
			AND B.intAssetId = FA.intAssetId
	) Adjustment
	WHERE 
		FA.ysnDepreciated = 1
		AND ISNULL(FA.ysnDisposed,0) = 0
		AND BD.intBookId = 1

	RETURN;
END
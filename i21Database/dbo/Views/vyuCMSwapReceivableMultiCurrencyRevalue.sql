CREATE VIEW [dbo].[vyuCMSwapReceivableMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Swap Receivables' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	strBankSwapId,
	strTransactionDate		=	SwapShort.dtmDate,
	strTransactionDueDate	=	SwapShort.dtmInTransit,
	strVendorName			=	'' COLLATE Latin1_General_CI_AS,
	strCommodity			=	'' COLLATE Latin1_General_CI_AS,
	strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS,
	strLocation				=	'' COLLATE Latin1_General_CI_AS,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	'' COLLATE Latin1_General_CI_AS,
	strItemId				=	'' COLLATE Latin1_General_CI_AS,
	dblQuantity				=	NULL,
	dblUnitPrice			=	NULL,
	dblAmount    			=   SwapShort.dblReceivableFx,
	intCurrencyId			=	SwapShort.intCurrencyIdAmountFrom,
	intForexRateType		=	SwapShort.intRateTypeIdAmountFrom,
	strForexRateType		=	RateType.strCurrencyExchangeRateType,
	dblForexRate			=	SwapShort.dblReceivableFn/SwapShort.dblReceivableFx,
	dblHistoricAmount		=	SwapShort.dblReceivableFn,
	dblAmountDifference		=	ISNULL(SwapShort.dblDifference, 0),
	dblNewForexRate         =   0, -- Calcuate By GL
    dblNewAmount            =   0, -- Calcuate By GL
    dblUnrealizedDebitGain  =   0, -- Calcuate By GL
    dblUnrealizedCreditGain =   0, -- Calcuate By GL
    dblDebit                =   0, -- Calcuate By GL
    dblCredit               =   0,  -- Calcuate By GL
	intCompanyLocationId	=	NULL,
	intAccountId			=	SwapShort.intGLAccountIdFrom,
	dtmSettlement			=	CASE WHEN ISNULL(SwapLong.ysnPosted, 0) = 1 THEN  SwapLong.dtmDate ELSE SwapShort.dtmDate END
FROM tblCMBankSwap BankSwap
JOIN tblCMBankTransfer SwapShort
	ON SwapShort.intTransactionId = BankSwap.intSwapShortId
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = SwapShort.intRateTypeIdAmountFrom
CROSS APPLY dbo.fnGLGetFiscalPeriod(SwapShort.dtmDate) P1
CROSS APPLY (
	SELECT TOP 1 ysnRevalue_Swap FROM tblCMCompanyPreferenceOption
	WHERE ysnRevalue_Swap = 1
) RevalueOptions
CROSS APPLY (
	SELECT TOP 1 P.intGLFiscalYearPeriodId, dtmDate, ysnPosted
	FROM tblCMBankTransfer 
	CROSS APPLY dbo.fnGLGetFiscalPeriod(dtmDate) P
	WHERE intTransactionId = BankSwap.intSwapLongId
) SwapLong
WHERE ISNULL(SwapShort.ysnPosted, 0) = 1
AND P1.intGLFiscalYearPeriodId <> SwapLong.intGLFiscalYearPeriodId

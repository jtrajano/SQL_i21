CREATE VIEW [dbo].[vyuCMSwapPayableMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Swap Payables' COLLATE Latin1_General_CI_AS,
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
	dblAmount    			=   SwapShort.dblPayableFx * -1,
	intCurrencyId			=	SwapShort.intCurrencyIdAmountTo,
	intForexRateType		=	SwapShort.intRateTypeIdAmountTo,
	strForexRateType		=	RateType.strCurrencyExchangeRateType,
	dblForexRate			=	SwapShort.dblPayableFn / SwapShort.dblPayableFx,
	dblHistoricAmount		=	SwapShort.dblPayableFn * -1,
	dblAmountDifference		=	ISNULL(SwapShort.dblDifference, 0),
	dblNewForexRate         =   0, -- Calcuate By GL
    dblNewAmount            =   0, -- Calcuate By GL
    dblUnrealizedDebitGain  =   0, -- Calcuate By GL
    dblUnrealizedCreditGain =   0, -- Calcuate By GL
    dblDebit                =   0, -- Calcuate By GL
    dblCredit               =   0,  -- Calcuate By GL
	intCompanyLocationId	=	NULL,
	intAccountId			=	SwapShort.intGLAccountIdTo,
	dtmSettlement			=	CASE WHEN ISNULL(SwapLong.ysnPosted, 0) = 1 THEN  SwapLong.dtmDate ELSE '2030-01-01' END
FROM tblCMBankSwap BankSwap
JOIN tblCMBankTransfer SwapShort
	ON SwapShort.intTransactionId = BankSwap.intSwapShortId
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = SwapShort.intRateTypeIdAmountTo
CROSS APPLY dbo.fnGLGetFiscalPeriod(SwapShort.dtmDate) P1
CROSS APPLY (
	SELECT TOP 1 ysnRevalue_Swap FROM tblCMCompanyPreferenceOption
	WHERE ysnRevalue_Swap = 1
) RevalueOptions
CROSS APPLY (
	SELECT TOP 1 P.intGLFiscalYearPeriodId, ysnPosted, dtmDate
	FROM tblCMBankTransfer 
	CROSS APPLY dbo.fnGLGetFiscalPeriod(dtmDate) P
	WHERE intTransactionId = BankSwap.intSwapLongId

) SwapLong
WHERE ISNULL(SwapShort.ysnPosted, 0) = 1
AND P1.intGLFiscalYearPeriodId <> SwapLong.intGLFiscalYearPeriodId


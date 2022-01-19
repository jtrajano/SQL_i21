CREATE VIEW [dbo].[vyuCMSwapInReceivablesMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Swap In With Swap Out Posted (Receivables)' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	BT.strTransactionId,
	strTransactionDate		=	BT.dtmDate,
	strTransactionDueDate	=	BT.dtmInTransit,
	strVendorName			=	'' COLLATE Latin1_General_CI_AS,
	strCommodity			=	'' COLLATE Latin1_General_CI_AS,
	strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS,
	strLocation				=	'' COLLATE Latin1_General_CI_AS,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	'' COLLATE Latin1_General_CI_AS,
	strItemId				=	'' COLLATE Latin1_General_CI_AS,
	dblQuantity				=	NULL,
	dblUnitPrice			=	NULL,
	dblAmount    			=   BT.dblAmountForeignTo,
	intCurrencyId			=	BT.intCurrencyIdAmountTo,
	intForexRateType		=	BT.intRateTypeIdAmountTo,
	strForexRateType		=	RateType.strCurrencyExchangeRateType,
	dblForexRate			=	BT.dblRateAmountTo,
	dblHistoricAmount		=	BT.dblAmountTo,
	dblAmountDifference		=	BT.dblDifference,
	dblNewForexRate         =   0, -- Calcuate By GL
    dblNewAmount            =   0, -- Calcuate By GL
    dblUnrealizedDebitGain  =   0, -- Calcuate By GL
    dblUnrealizedCreditGain =   0, -- Calcuate By GL
    dblDebit                =   0, -- Calcuate By GL
    dblCredit               =   0  -- Calcuate By GL
FROM tblCMBankSwap BankSwap
JOIN tblCMBankTransfer BT
	ON BT.intTransactionId = BankSwap.intSwapLongId
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = BT.intRateTypeIdAmountTo
OUTER APPLY (
	SELECT TOP 1 ysnRevalue_Swap FROM tblCMCompanyPreferenceOption
) RevalueOptions
OUTER APPLY (
	SELECT TOP 1 ISNULL(ysnPosted, 0) ysnPosted FROM tblCMBankTransfer WHERE intTransactionId = BankSwap.intSwapShortId
) SwapOut
WHERE
	BT.ysnPosted = 0
	AND BT.ysnPostedInTransit = 0
	AND RevalueOptions.ysnRevalue_Swap = 1
	AND ISNULL(SwapOut.ysnPosted, 0) = 1
	AND BT.intBankTransferTypeId = 5

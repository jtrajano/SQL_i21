CREATE VIEW [dbo].[vyuCMForwardPayablesMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Forward Payables' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	BT.strTransactionId,
	strTransactionDate		=	BT.dtmAccrual,
	strTransactionDueDate	=	BT.dtmDate,
	strVendorName			=	'' COLLATE Latin1_General_CI_AS,
	strCommodity			=	'' COLLATE Latin1_General_CI_AS,
	strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS,
	strLocation				=	'' COLLATE Latin1_General_CI_AS,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	'' COLLATE Latin1_General_CI_AS,
	strItemId				=	'' COLLATE Latin1_General_CI_AS,
	dblQuantity				=	NULL,
	dblUnitPrice			=	NULL,
	dblAmount    			=   BT.dblAmountForeignFrom,
	intCurrencyId			=	BT.intCurrencyIdAmountFrom,
	intForexRateType		=	BT.intRateTypeIdAmountFrom,
	strForexRateType		=	RateType.strCurrencyExchangeRateType,
	dblForexRate			=	BT.dblRateAmountFrom,
	dblHistoricAmount		=	BT.dblAmountFrom,
	dblAmountDifference		=	0,
	dblNewForexRate         =   0, -- Calcuate By GL
    dblNewAmount            =   0, -- Calcuate By GL
    dblUnrealizedDebitGain  =   0, -- Calcuate By GL
    dblUnrealizedCreditGain =   0, -- Calcuate By GL
    dblDebit                =   0, -- Calcuate By GL
    dblCredit               =   0  -- Calcuate By GL
FROM tblCMBankTransfer BT
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = BT.intRateTypeIdAmountFrom
OUTER APPLY (
	SELECT TOP 1 ysnRevalue_Forward FROM tblCMCompanyPreferenceOption
) RevalueOptions
WHERE
	BT.ysnPosted = 0
	AND BT.ysnPostedInTransit = 1
	AND RevalueOptions.ysnRevalue_Forward = 1

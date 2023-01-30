CREATE VIEW [dbo].[vyuCMForwardReceivablesMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Forward Receivables' COLLATE Latin1_General_CI_AS,
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
	dblAmount    			=   BT.dblAmountForeignTo,
	intCurrencyId			=	BT.intCurrencyIdAmountTo,
	intForexRateType		=	BT.intRateTypeIdAmountTo,
	strForexRateType		=	RateType.strCurrencyExchangeRateType,
	dblForexRate			=	BT.dblRateAmountTo,
	dblHistoricAmount		=	BT.dblAmountTo,
	dblAmountDifference		=	ISNULL(BT.dblDifference, 0),
	dblNewForexRate         =   0, -- Calcuate By GL
    dblNewAmount            =   0, -- Calcuate By GL
    dblUnrealizedDebitGain  =   0, -- Calcuate By GL
    dblUnrealizedCreditGain =   0, -- Calcuate By GL
    dblDebit                =   0, -- Calcuate By GL
    dblCredit               =   0,  -- Calcuate By GL
	intCompanyLocationId	=	NULL,
	intAccountId			=	BT.intGLAccountIdTo,
	intLOBSegmentCodeId		= 	ISNULL(DER.intSegmentCodeId, DER1.intSegmentCodeId)
FROM tblCMBankTransfer BT
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = BT.intRateTypeIdAmountTo
OUTER APPLY (
	SELECT TOP 1 ysnRevalue_Forward FROM tblCMCompanyPreferenceOption
) RevalueOptions
OUTER APPLY(
    SELECT TOP 1 SM.intSegmentCodeId
    FROM tblRKFutOptTransaction der
    JOIN tblICCommodity C
        ON C.intCommodityId = der.intCommodityId
    JOIN tblSMLineOfBusiness SM ON SM.intLineOfBusinessId = C.intLineOfBusinessId
    WHERE der.strInternalTradeNo = BT.strDerivativeId
)DER
OUTER APPLY(
    SELECT TOP 1 SM.intSegmentCodeId
    FROM tblRKFutOptTransaction der
    JOIN tblCTContractDetail CD
        ON CD.intContractDetailId = der.intContractDetailId
    JOIN tblCTContractHeader CH
        ON CH.intContractHeaderId = CD.intContractDetailId
    JOIN tblICCommodity C
        ON C.intCommodityId = CH.intCommodityId
    JOIN tblSMLineOfBusiness SM ON SM.intLineOfBusinessId = C.intLineOfBusinessId
    WHERE der.strInternalTradeNo = BT.strDerivativeId
)DER1
WHERE
	BT.ysnPosted = 0
	AND BT.ysnPostedInTransit = 1
	AND RevalueOptions.ysnRevalue_Forward = 1
	AND BT.intBankTransferTypeId = 3

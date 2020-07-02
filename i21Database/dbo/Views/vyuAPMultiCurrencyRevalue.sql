CREATE VIEW [dbo].[vyuAPMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Voucher' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	A.strBillId,
	strTransactionDate		=	A.dtmDate,
	strTransactionDueDate	=	A.dtmDueDate,
	strVendorName			=	B2.strName,
	strCommodity			=	CC.strDescription,
	strLineOfBusiness		=	CT.strDescription,
	strLocation				=	EL.strLocationName,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	CH.strContractNumber,
	strItemId				=	strName,
	dblQuantity				=	BD.dblQtyReceived,
	dblUnitPrice			=	0,
	dblAmount				=	A.dblTotal,
	intCurrencyId			=	A.intCurrencyId,
	intForexRateType		=	BD.intCurrencyExchangeRateTypeId,
	strForexRateType		=	CER.strCurrencyExchangeRateType,
	dblForexRate			=	BD.dblRate,
	dblHistoricAmount		=	A.dblTotal * BD.dblRate,
	dblNewForexRate         =    0, --Calcuate By GL
    dblNewAmount            =    0, --Calcuate By GL
    dblUnrealizedDebitGain  =    0, --Calcuate By GL
    dblUnrealizedCreditGain =    0, --Calcuate By GL
    dblDebit                =    0, --Calcuate By GL
    dblCredit               =    0  --Calcuate By GL
FROM tblAPBill A
INNER JOIN tblAPBillDetail BD
	ON BD.intBillId = A.intBillId
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.[intEntityId] = B2.intEntityId) 
	ON A.intEntityVendorId = B.[intEntityId]
LEFT JOIN dbo.tblEMEntityLocation EL
	ON EL.intEntityLocationId = A.intShipFromId
LEFT JOIN dbo.tblCTContractHeader CH 
	ON CH.intContractHeaderId = BD.intContractHeaderId
LEFT JOIN tblICItem IT
	ON BD.intItemId = IT.intItemId
LEFT JOIN dbo.tblICCategory CT
	ON IT.intCategoryId = CT.intCategoryId
LEFT JOIN dbo.tblICCommodity CC
	ON CC.intCommodityId = IT.intCommodityId
LEFT JOIN dbo.tblSMCurrencyExchangeRateType CER
	ON CER.intCurrencyExchangeRateTypeId = BD.intCurrencyExchangeRateTypeId
WHERE A.ysnPosted = 1 AND A.ysnPaid = 0


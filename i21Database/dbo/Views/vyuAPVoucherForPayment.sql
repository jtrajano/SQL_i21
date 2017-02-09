CREATE VIEW [dbo].[vyuAPVoucherForPayment]
AS
SELECT 
	strTransactionType		=	'Voucher',
	strTransactionId		=	A.strBillId,
	strTransactionDate		=	A.dtmDate,
	strTransactionDueDate	=	A.dtmDueDate,
	strVendorName			=	B2.strName,
	strCommodity			=	'',
	strLineOfBusiness		=	'',
	strLocation				=	'',
	strTicket				=	'',
	strContractNumber		=	'',
	strItemId				=	'',
	dblQuantity				=	0,
	dblUnitPrice			=	0,
	dblAmount				=	0,
	intCurrencyId			=	0,
	intForexRateType		=	0,
	dblForexRate			=	0,
	dblHistoricAmount		=	0,
	dblNewForexRate			=	0,
	dblNewAmount			=	0,
	dblUnrealizedDebitGain	=	0,
	dblUnrealizedCreditGain	=	0,
	dblDebit				=	0,
	dblCredit				=	0
FROM tblAPBill A
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId) 
	ON A.intEntityVendorId = B.intEntityVendorId
WHERE A.ysnPosted = 1 AND A.ysnPaid = 0

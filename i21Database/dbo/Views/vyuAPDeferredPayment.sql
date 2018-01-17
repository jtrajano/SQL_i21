CREATE VIEW [dbo].[vyuAPDeferredPayment]
AS

SELECT
	A.intBillId,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	A.strBillId,
	B.strName,
	A.dtmBillDate,
	A.dtmDate,
	term.strTerm,
	A.dtmDueDate
FROM tblAPBill A
INNER JOIN tblEMEntity B ON A.intEntityVendorId = B.intEntityId
CROSS APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
LEFT JOIN tblSMTerm term ON A.intTermsId = term.intTermID

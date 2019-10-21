CREATE VIEW [dbo].[vyuAPBillDeferredInterest]
AS 

SELECT 
	deferredInterest.intDeferredVoucherId AS intBillId,
	deferredInterest.strVendorOrderNumber,
	deferredInterest.dtmDate,
	deferredInterest.dtmBillDate,
	term.strTerm,
	deferredInterest.dtmDueDate,
	deferredInterest.strReference,
	payToLoc.strCheckPayeeName AS strPayTo,
	cur.strCurrency,
	NULL AS strPrincipal,
	0.00 AS dblInterestRate,
	deferredInterest.dblTotal AS dblInterest,
	deferredInterest.dblAmountDue,
	0 AS intDaysInterest
FROM tblAPBill deferredInterest 
INNER JOIN tblSMTerm term ON deferredInterest.intTermsId = term.intTermID
INNER JOIN tblEMEntityLocation payToLoc ON deferredInterest.intPayToAddressId = payToLoc.intEntityLocationId
INNER JOIN tblSMCurrency cur ON deferredInterest.intCurrencyId = cur.intCurrencyID
WHERE deferredInterest.intTransactionType = 14

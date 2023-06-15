CREATE VIEW [dbo].[vyuAPCorriganPaymentToIPayables]
AS

SELECT
	'01' AS strRecordCode,
	'C0000549' AS strCustomerID,
	D.strVendorId AS strVendorNbr,
	'0090' AS strBusinessUnit,
	C.strVendorOrderNumber AS strInvoiceNbr,
	C.dtmBillDate AS dtmInvoiceDate,
	'NULL' AS strPONbr,
	C.dtmDueDate AS dtmInvoiceDueDate,
	A.strPaymentRecordNum AS strPaymentRefNbr,
	A.dtmDatePaid AS dtmPaymentDate,
	CASE
		WHEN E.strPaymentMethod = 'Check' THEN 'CHCK'
		WHEN E.strPaymentMethod = 'eCheck' THEN 'VCRD'
		WHEN E.strPaymentMethod = 'ACH' THEN 'CACH'
	ELSE 'NULL'
	END AS strPaymentType,
	C.dblTotal AS dblInvoiceTotal,
	B.dblDiscount AS dblDiscountAmount,
	B.dblPayment AS dblNetAmount,
	B.dblPayment AS dblPayment,
	F.strCurrency,
	CASE
		WHEN G.dtmCheckPrinted IS NOT NULL THEN 'PAID'
		WHEN E.strPaymentMethod NOT IN ('ACH','Check') AND A.ysnPosted = 1 THEN 'PAID'
		WHEN A.ysnPosted = 1 THEN 'RCVD'
	ELSE 'RCVD' END AS strStatus,
	G.dtmClr AS dtmClearedDate,
	'iRely i21' AS strStatusMessage,
	C.strBillId AS strVoucherNbr,
	'NULL' AS strPaymentRoutingCode,
	H.strTerm AS strTerms,
	A.dtmDatePaid AS dtmAccountingPeriod
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
INNER JOIN (tblAPVendor D INNER JOIN tblEMEntity D2 ON D.intEntityId = D2.intEntityId) ON A.intEntityVendorId = D.intEntityId
INNER JOIN tblSMPaymentMethod E ON A.intPaymentMethodId = E.intPaymentMethodID
INNER JOIN tblSMCurrency F ON F.intCurrencyID = A.intCurrencyId
INNER JOIN tblCMBankTransaction G ON A.strPaymentRecordNum = G.strTransactionId
INNER JOIN tblSMTerm H ON C.intTermsId = H.intTermID
UNION ALL
SELECT
	'01' AS strRecordCode,
	'C0000549' AS strCustomerID,
	D.strVendorId AS strVendorNbr,
	'0090' AS strBusinessUnit,
	C.strInvoiceNumber AS strInvoiceNbr,
	C.dtmDate AS dtmInvoiceDate,
	'NULL' AS strPONbr,
	C.dtmDueDate AS dtmInvoiceDueDate,
	A.strPaymentRecordNum AS strPaymentRefNbr,
	A.dtmDatePaid AS dtmPaymentDate,
	CASE
		WHEN E.strPaymentMethod = 'Check' THEN 'CHCK'
		WHEN E.strPaymentMethod = 'eCheck' THEN 'VCRD'
		WHEN E.strPaymentMethod = 'ACH' THEN 'CACH'
	ELSE 'NULL'
	END AS strPaymentType,
	C.dblInvoiceTotal AS dblInvoiceTotal,
	B.dblDiscount AS dblDiscountAmount,
	B.dblPayment AS dblNetAmount,
	B.dblPayment AS dblPayment,
	F.strCurrency,
	CASE
		WHEN G.dtmCheckPrinted IS NOT NULL THEN 'PAID'
		WHEN E.strPaymentMethod NOT IN ('ACH','Check') AND A.ysnPosted = 1 THEN 'PAID'
		WHEN A.ysnPosted = 1 THEN 'RCVD'
	ELSE 'RCVD' END AS strStatus,
	G.dtmClr AS dtmClearedDate,
	'iRely i21' AS strStatusMessage,
	C.strInvoiceNumber AS strVoucherNbr,
	'NULL' AS strPaymentRoutingCode,
	H.strTerm AS strTerms,
	A.dtmDatePaid AS dtmAccountingPeriod
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblARInvoice C ON B.intBillId = C.intInvoiceId
INNER JOIN (tblAPVendor D INNER JOIN tblEMEntity D2 ON D.intEntityId = D2.intEntityId) ON A.intEntityVendorId = D.intEntityId
INNER JOIN tblSMPaymentMethod E ON A.intPaymentMethodId = E.intPaymentMethodID
INNER JOIN tblSMCurrency F ON F.intCurrencyID = A.intCurrencyId
INNER JOIN tblCMBankTransaction G ON A.strPaymentRecordNum = G.strTransactionId
INNER JOIN tblSMTerm H ON C.intTermId = H.intTermID
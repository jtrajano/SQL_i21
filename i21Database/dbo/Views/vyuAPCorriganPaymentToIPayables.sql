CREATE  VIEW [dbo].[vyuAPCorriganPaymentToIPayables]
AS

WITH payInfo (
	strRecordCode,
	strCustomerID,
	strVendorNbr,
	strBusinessUnit,
	strInvoiceNbr,
	dtmInvoiceDate,
	strPONbr,
	dtmInvoiceDueDate,
	strPaymentRefNbr,
	dtmPaymentDate,
	strPaymentType,
	dblInvoiceTotal,
	dblDiscountAmount,
	dblNetAmount,
	dblPayment,
	strCurrency,
	strStatus,
	dtmClearedDate,
	strStatusMessage,
	strVoucherNbr,
	strPaymentRoutingCode,
	strTerms,
	dtmAccountingPeriod
) AS (
	SELECT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerID,
		D2.strEntityNo AS strVendorNbr,
		'0090' AS strBusinessUnit,
		C.strVendorOrderNumber AS strInvoiceNbr,
		FORMAT(CAST(C.dtmBillDate AS DATE), 'yyyy-MM-dd') AS dtmInvoiceDate,
		'NULL' AS strPONbr,
		FORMAT(CAST(C.dtmDueDate AS DATE), 'yyyy-MM-dd') AS dtmInvoiceDueDate,
		A.strPaymentRecordNum AS strPaymentRefNbr,
		FORMAT(CAST(A.dtmDatePaid AS DATE), 'yyyy-MM-dd') AS dtmPaymentDate,
		CASE
			WHEN E.strPaymentMethod = 'Check' THEN 'CHCK'
			WHEN E.strPaymentMethod = 'eCheck' THEN 'VCRD'
			WHEN E.strPaymentMethod = 'ACH' THEN 'CACH'
		ELSE 'NULL'
		END AS strPaymentType,
		B.dblTotal AS dblInvoiceTotal,
		B.dblDiscount AS dblDiscountAmount,
		B.dblPayment AS dblNetAmount,
		B.dblPayment AS dblPayment,
		F.strCurrency,
		CASE
			WHEN G.dtmCheckPrinted IS NOT NULL THEN 'PAID'
			WHEN E.strPaymentMethod NOT IN ('ACH','Check') AND A.ysnPosted = 1 THEN 'PAID'
			WHEN A.ysnPosted = 1 THEN 'RCVD'
		ELSE '' END AS strStatus,
		FORMAT(CAST(G.dtmClr AS DATE), 'yyyy-MM-dd') AS dtmClearedDate,
		'iRely i21' AS strStatusMessage,
		C.strBillId AS strVoucherNbr,
		'NULL' AS strPaymentRoutingCode,
		H.strTermCode AS strTerms,
		FORMAT(CAST(A.dtmDatePaid AS DATE), 'yyyy-MM-dd') AS dtmAccountingPeriod
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
	INNER JOIN (tblAPVendor D INNER JOIN tblEMEntity D2 ON D.intEntityId = D2.intEntityId) ON A.intEntityVendorId = D.intEntityId
	INNER JOIN tblSMPaymentMethod E ON A.intPaymentMethodId = E.intPaymentMethodID
	INNER JOIN tblSMCurrency F ON F.intCurrencyID = A.intCurrencyId
	INNER JOIN tblSMTerm H ON C.intTermsId = H.intTermID
	LEFT JOIN tblCMBankTransaction G ON A.strPaymentRecordNum = G.strTransactionId
	-- WHERE
	-- 	A.ysnPosted = 1
	-- AND G.ysnCheckVoid = 0
	UNION ALL
	SELECT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerID,
		D2.strEntityNo AS strVendorNbr,
		'0090' AS strBusinessUnit,
		C.strInvoiceNumber AS strInvoiceNbr,
		FORMAT(CAST(C.dtmDate AS DATE), 'yyyy-MM-dd') AS dtmInvoiceDate,
		'NULL' AS strPONbr,
		FORMAT(CAST(C.dtmDueDate AS DATE), 'yyyy-MM-dd') AS dtmInvoiceDueDate,
		A.strPaymentRecordNum AS strPaymentRefNbr,
		FORMAT(CAST(A.dtmDatePaid AS DATE), 'yyyy-MM-dd') AS dtmPaymentDate,
		CASE
			WHEN E.strPaymentMethod = 'Check' THEN 'CHCK'
			WHEN E.strPaymentMethod = 'eCheck' THEN 'VCRD'
			WHEN E.strPaymentMethod = 'ACH' THEN 'CACH'
		ELSE 'NULL'
		END AS strPaymentType,
		B.dblTotal AS dblInvoiceTotal,
		B.dblDiscount AS dblDiscountAmount,
		B.dblPayment AS dblNetAmount,
		B.dblPayment AS dblPayment,
		F.strCurrency,
		CASE
			WHEN G.dtmCheckPrinted IS NOT NULL THEN 'PAID'
			WHEN E.strPaymentMethod NOT IN ('ACH','Check') AND A.ysnPosted = 1 THEN 'PAID'
			WHEN A.ysnPosted = 1 THEN 'RCVD'
		ELSE '' END AS strStatus,
		FORMAT(CAST(G.dtmClr AS DATE), 'yyyy-MM-dd') AS dtmClearedDate,
		'iRely i21' AS strStatusMessage,
		C.strInvoiceNumber AS strVoucherNbr,
		'NULL' AS strPaymentRoutingCode,
		H.strTermCode AS strTerms,
		FORMAT(CAST(A.dtmDatePaid AS DATE), 'yyyy-MM-dd') AS dtmAccountingPeriod
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN tblARInvoice C ON B.intInvoiceId = C.intInvoiceId
	INNER JOIN (tblAPVendor D INNER JOIN tblEMEntity D2 ON D.intEntityId = D2.intEntityId) ON A.intEntityVendorId = D.intEntityId
	INNER JOIN tblSMPaymentMethod E ON A.intPaymentMethodId = E.intPaymentMethodID
	INNER JOIN tblSMCurrency F ON F.intCurrencyID = A.intCurrencyId
	INNER JOIN tblSMTerm H ON C.intTermId = H.intTermID
	LEFT JOIN tblCMBankTransaction G ON A.strPaymentRecordNum = G.strTransactionId
	-- WHERE
	-- 	A.ysnPosted = 1
	-- AND G.ysnCheckVoid = 0
)


--SELECT * FROM payInfo

SELECT TOP 100 PERCENT
	strRecordCode, strCustomerID,
	+ strVendorNbr + '|' 
	+ strBusinessUnit + '|' + ISNULL(strInvoiceNbr,'') + '|' + CAST(dtmInvoiceDate AS NVARCHAR(100))+ '|' + ISNULL(strPONbr,'') + '|' + ISNULL(dtmInvoiceDueDate,'') + '|' + ISNULL(strPaymentRefNbr,'')
	+ '|' + ISNULL(dtmPaymentDate,'') + '|' + ISNULL(strPaymentType,'') + '|' + CAST(dblInvoiceTotal AS NVARCHAR(100))+ '|' + CAST(dblDiscountAmount AS NVARCHAR(100)) + '|' + CAST(dblNetAmount AS NVARCHAR(100)) 
	+ '|' + CAST(dblPayment AS NVARCHAR(100)) + '|' + strCurrency
	+ '|' + ISNULL(strStatus,'') + '|' + ISNULL(dtmClearedDate,'') + '|' + ISNULL(strStatusMessage,'') + '|' + ISNULL(strVoucherNbr,'') + '|' + ISNULL(strPaymentRoutingCode,'') 
	+ '|' + ISNULL(strTerms,'') + '|' + ISNULL(dtmAccountingPeriod,'')
	AS strData
FROM payInfo A
ORDER BY strPaymentRefNbr DESC
UNION ALL
SELECT
	'99', strCustomerID, CAST(intCount AS NVARCHAR(100)) + '|' + CAST(dblInvoiceAmountTotal AS NVARCHAR(100))
FROM (
	SELECT
		strRecordCode, strCustomerID, COUNT(*) AS intCount, SUM(CAST(dblInvoiceTotal AS DECIMAL(18,2))) AS dblInvoiceAmountTotal
	FROM payInfo
	GROUP BY strRecordCode, strCustomerID
) tmp
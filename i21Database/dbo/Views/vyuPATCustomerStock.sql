CREATE VIEW [dbo].[vyuPATCustomerStock]
	AS
SELECT	CS.intCustomerStockId,
		CS.intCustomerPatronId,
		C.strName,
		CS.intStockId,
		PC.strStockName,
		CS.strCertificateNo,
		CS.strStockStatus,
		CS.dblSharesNo,
		CS.dtmRetireDate,
		CS.dtmIssueDate,
		CS.strActivityStatus,
		CS.intTransferredFrom,
		CT.strName AS strTransferredFrom,
		CS.dtmTransferredDate,
		CS.dblParValue,
		CS.dblFaceValue,
		ARI.strInvoiceNumber,
		APB.strBillId,
		strCheckNumber = CASE WHEN CS.intBillId IS NULL THEN ARPAY.strPaymentInfo ELSE APPAY.strPaymentInfo END,
		dtmCheckDate = CASE WHEN CS.intBillId IS NULL THEN ARPAY.dtmDatePaid ELSE APPAY.dtmDatePaid END,
		dblCheckAmount = CASE WHEN CS.intBillId IS NULL THEN ARPAY.dblPayment ELSE APPAY.dblPayment END,
		ysnPosted = CASE WHEN ISNULL(CS.ysnPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		ysnRetiredPosted = CASE WHEN ISNULL(CS.ysnRetiredPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		CS.intConcurrencyId
	FROM tblPATCustomerStock CS
	INNER JOIN tblEMEntity C
		ON C.intEntityId = CS.intCustomerPatronId
	INNER JOIN tblPATStockClassification PC
		ON PC.intStockId = CS.intStockId
	LEFT OUTER JOIN tblEMEntity CT
		ON CT.intEntityId = CS.intTransferredFrom
	LEFT OUTER JOIN tblAPBill APB
		ON APB.intBillId = CS.intBillId
	LEFT OUTER JOIN tblARInvoice ARI
		ON ARI.intInvoiceId = CS.intInvoiceId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intBillId, A.dtmDatePaid, B.dblPayment FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId) APPAY
		ON APPAY.intBillId = CS.intBillId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intInvoiceId, A.dtmDatePaid, B.dblPayment FROM tblARPayment A INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId) ARPAY
		ON ARPAY.intInvoiceId = CS.intInvoiceId

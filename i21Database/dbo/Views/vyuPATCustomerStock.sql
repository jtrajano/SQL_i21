CREATE VIEW [dbo].[vyuPATCustomerStock]
	AS
SELECT	CS.intCustomerStockId,
		CS.intCustomerPatronId,
		IssueStk.intIssueStockId,
		IssueStk.strIssueNo,
		IssueStk.dtmIssueDate,
		C.strName,
		CS.intStockId,
		PC.strStockName,
		CS.strCertificateNo,
		CS.strStockStatus,
		CS.dblSharesNo,
		RetireStk.intRetireStockId,
		RetireStk.strRetireNo,
		RetireStk.dtmRetireDate,
		CS.strActivityStatus,
		CS.intTransferredFrom,
		CT.strName AS strTransferredFrom,
		CS.dtmTransferredDate,
		CS.dblParValue,
		CS.dblFaceValue,
		IssueStk.intInvoiceId,
		ARI.strInvoiceNumber,
		RetireStk.intBillId,
		APB.strBillId,
		strCheckNumber = CASE WHEN RetireStk.intBillId IS NULL THEN ARPAY.strPaymentInfo ELSE APPAY.strPaymentInfo END,
		dtmCheckDate = CASE WHEN RetireStk.intBillId IS NULL THEN ARPAY.dtmDatePaid ELSE APPAY.dtmDatePaid END,
		dblCheckAmount = CASE WHEN RetireStk.intBillId IS NULL THEN ARPAY.dblPayment ELSE APPAY.dblPayment END,
		ysnPosted = CASE WHEN ISNULL(IssueStk.ysnPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		ysnRetiredPosted = CASE WHEN ISNULL(RetireStk.ysnPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		CS.intConcurrencyId
	FROM tblPATCustomerStock CS
	INNER JOIN tblEMEntity C
		ON C.intEntityId = CS.intCustomerPatronId
	INNER JOIN tblPATStockClassification PC
		ON PC.intStockId = CS.intStockId
	LEFT OUTER JOIN tblPATIssueStock IssueStk
		ON IssueStk.intCustomerStockId = CS.intCustomerStockId
	LEFT OUTER JOIN tblPATRetireStock RetireStk
		ON RetireStk.intCustomerStockId = CS.intCustomerStockId
	LEFT OUTER JOIN tblEMEntity CT
		ON CT.intEntityId = CS.intTransferredFrom
	LEFT OUTER JOIN tblAPBill APB
		ON APB.intBillId = RetireStk.intBillId
	LEFT OUTER JOIN tblARInvoice ARI
		ON ARI.intInvoiceId = IssueStk.intInvoiceId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intBillId, A.dtmDatePaid, B.dblPayment FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId) APPAY
		ON APPAY.intBillId = RetireStk.intBillId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intInvoiceId, A.dtmDatePaid, B.dblPayment FROM tblARPayment A INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId) ARPAY
		ON ARPAY.intInvoiceId = IssueStk.intInvoiceId
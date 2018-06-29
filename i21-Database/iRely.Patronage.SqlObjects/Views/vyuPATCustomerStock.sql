CREATE VIEW [dbo].[vyuPATCustomerStock]
	AS
SELECT	IssueStk.intIssueStockId,
		IssueStk.strIssueNo,
		IssueStk.dtmIssueDate,
		CS.intCustomerStockId,
		IssueStk.intCustomerPatronId,
		Customer.strEntityNo,
		Customer.strName,
		IssueStk.intStockId,
		PC.strStockName,
		IssueStk.strCertificateNo,
		IssueStk.strStockStatus,
		IssueStk.dblSharesNo,
		RetireStk.intRetireStockId,
		RetireStk.strRetireNo,
		RetireStk.dtmRetireDate,
		strActivityStatus = ISNULL(CS.strActivityStatus,'Open'),
		CS.intTransferredFrom,
		TransferCustomer.strName AS strTransferredFrom,
		CS.dtmTransferredDate,
		IssueStk.dblParValue,
		IssueStk.dblFaceValue,
		IssueStk.intInvoiceId,
		ARI.strInvoiceNumber,
		strCheckNumber = ARPAY.strPaymentInfo,
		dtmCheckDate = ARPAY.dtmDatePaid,
		dblCheckAmount = ARPAY.dblPayment,
		ysnPosted = CASE WHEN ISNULL(IssueStk.ysnPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		RetireStk.intBillId,
		APB.strBillId,
		strRetireCheckNumber = APPAY.strPaymentInfo,
		dtmRetireCheckDate = APPAY.dtmDatePaid,
		dblRetireCheckAmount = APPAY.dblPayment,
		ysnRetiredPosted = CASE WHEN ISNULL(RetireStk.ysnPosted, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		IssueStk.intConcurrencyId
	FROM tblPATIssueStock IssueStk
	INNER JOIN tblEMEntity Customer
		ON Customer.intEntityId = IssueStk.intCustomerPatronId
	INNER JOIN tblPATStockClassification PC
		ON PC.intStockId = IssueStk.intStockId
	LEFT OUTER JOIN tblPATCustomerStock CS
		ON CS.intCustomerStockId = IssueStk.intCustomerStockId
	LEFT OUTER JOIN tblPATRetireStock RetireStk
		ON RetireStk.intCustomerStockId = CS.intCustomerStockId
	LEFT OUTER JOIN tblEMEntity TransferCustomer
		ON TransferCustomer.intEntityId = CS.intTransferredFrom
	LEFT OUTER JOIN tblAPBill APB
		ON APB.intBillId = RetireStk.intBillId
	LEFT OUTER JOIN tblARInvoice ARI
		ON ARI.intInvoiceId = IssueStk.intInvoiceId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intBillId, A.dtmDatePaid, B.dblPayment FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId) APPAY
		ON APPAY.intBillId = RetireStk.intBillId
	LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intInvoiceId, A.dtmDatePaid, B.dblPayment FROM tblARPayment A INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId) ARPAY
		ON ARPAY.intInvoiceId = IssueStk.intInvoiceId
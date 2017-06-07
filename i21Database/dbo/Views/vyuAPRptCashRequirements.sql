CREATE VIEW [dbo].[vyuAPRptCashRequirements]
WITH SCHEMABINDING
AS
SELECT
		APV.[intEntityId],
		APV.strVendorId,
		ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName,
		--dbo.tblAPPayment.dtmDatePaid,
		APB.strBillId,
		APB.dtmDate,
		APB.dtmDueDate,
		APB.dtmDiscountDate,
		APPD.dblPayment,
		APPD.dblDiscount,
		APP.dblUnapplied,
		APP.dblWithheld,
		APP.dblAmountPaid
	FROM dbo.tblAPVendor APV
	INNER JOIN dbo.tblAPPayment APP
		ON APP.intEntityVendorId = APV.[intEntityId]
	INNER JOIN dbo.tblAPPaymentDetail APPD
		ON APP.intPaymentId = APPD.intPaymentId
	INNER JOIN dbo.tblAPBill APB
		ON APB.intBillId = APPD.intBillId
	LEFT JOIN dbo.tblEMEntity E
		ON E.intEntityId = APV.[intEntityId]
	WHERE 
			APB.ysnForApproval != 1														   --Will not show For Approval Bills
		AND APB.ysnPosted = 1 OR (APB.dtmApprovalDate IS NOT NULL AND APB.ysnApproved = 1) --Will not show Rejected approval bills but show old Posted Transactions.
		AND APB.intTransactionType != 6													   --Will not show BillTemplate
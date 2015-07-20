CREATE VIEW [dbo].[vyuAPRptCashRequirements]
WITH SCHEMABINDING
AS
SELECT
		APV.intEntityVendorId,
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
		ON APP.intEntityVendorId = APV.intEntityVendorId
	INNER JOIN dbo.tblAPPaymentDetail APPD
		ON APP.intPaymentId = APPD.intPaymentId
	INNER JOIN dbo.tblAPBill APB
		ON APB.intBillId = APPD.intBillId
	LEFT JOIN dbo.tblEntity E
		ON E.intEntityId = APV.intEntityVendorId
	WHERE 
			APB.ysnForApproval != 1									   --Will not show For Approval Bills
		AND (APB.ysnApproved = 0 AND APB.dtmApprovalDate IS NULL)      --Will not show Rejected approval bills
		AND APB.intTransactionType != 6                                --Will not show BillTemplate
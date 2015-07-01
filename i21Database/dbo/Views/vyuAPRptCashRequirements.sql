CREATE VIEW [dbo].[vyuAPRptCashRequirements]
WITH SCHEMABINDING
AS
SELECT
	dbo.tblAPVendor.intEntityVendorId,
	dbo.tblAPVendor.strVendorId,
	ISNULL(tblAPVendor.strVendorId, '') + ' - ' + isnull(tblEntity.strName,'''') as strVendorIdName,
	--dbo.tblAPPayment.dtmDatePaid,
	dbo.tblAPBill.strBillId,
	dbo.tblAPBill.dtmDate,
	dbo.tblAPBill.dtmDueDate,
	dbo.tblAPBill.dtmDiscountDate,
	dbo.tblAPPaymentDetail.dblPayment,
	dbo.tblAPPaymentDetail.dblDiscount,
	dbo.tblAPPayment.dblUnapplied,
	dbo.tblAPPayment.dblWithheld,
	dbo.tblAPPayment.dblAmountPaid
FROM dbo.tblAPVendor
INNER JOIN dbo.tblAPPayment
ON tblAPPayment.intEntityVendorId = tblAPVendor.intEntityVendorId
INNER JOIN dbo.tblAPPaymentDetail
ON dbo.tblAPPayment.intPaymentId = dbo.tblAPPaymentDetail.intPaymentId
INNER JOIN dbo.tblAPBill
ON dbo.tblAPBill.intBillId = dbo.tblAPPaymentDetail.intBillId
INNER JOIN dbo.tblAPBillBatch
ON dbo.tblAPBill.intBillBatchId = dbo.tblAPBillBatch.intBillBatchId
LEFT JOIN dbo.tblEntity
ON dbo.tblEntity.intEntityId = dbo.tblAPVendor.intEntityVendorId

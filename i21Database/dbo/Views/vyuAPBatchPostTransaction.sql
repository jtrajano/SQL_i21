CREATE VIEW [dbo].[vyuAPBatchPostTransaction] 
AS
SELECT 'Voucher' COLLATE Latin1_General_CI_AS AS strTransactionType,
       A.intBillId,
       A.strBillId,
       A.dblTotal,
       A.strVendorOrderNumber,
       A.intEntityVendorId,
       A.intEntityId,
       A.dtmDate,
       A.strComment AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPBill A
WHERE intTransactionType = 1
 AND ISNULL(ysnPosted, 0) = 0
 AND NOT EXISTS(
	SELECT 1 FROM vyuAPForApprovalTransaction B WHERE A.intBillId = B.intTransactionId AND B.strScreenName = 'Voucher'
 )
 AND A.ysnRecurring = 0
UNION ALL
SELECT DISTINCT
	'Payable' AS strTransactionType,
       A.intPaymentId,
       strPaymentRecordNum,
       dblAmountPaid,
       '' AS strVendorInvoiceNumber,
       intEntityVendorId AS intEntityVendorId,
       intEntityId,
       dtmDatePaid,
       strNotes AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
WHERE (ysnPosted = 0 AND ISNULL(strPaymentInfo, '') NOT LIKE 'Voided%')
--and dblAmountPaid != 0
--AND NOT EXISTS  ( SELECT intBillId FROM vyuAPBillPayment C WHERE C.ysnPaid = 1 AND C.ysnVoid = 0 AND B.intBillId = C.intBillId )
UNION ALL
SELECT 'Debit Memo' AS strTransactionType,
       intBillId,
       strBillId,
       dblTotal * -1,
       strVendorOrderNumber,
       intEntityVendorId,
       intEntityId,
       dtmDate,
       strComment AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPBill
WHERE intTransactionType = 3
AND ISNULL(ysnPosted, 0) = 0
UNION ALL
SELECT 'Vendor Prepayment' AS strTransactionType,
       intBillId,
       strBillId,
       dblTotal,
       strVendorOrderNumber,
       intEntityVendorId,
       intEntityId,
       dtmDate,
       strComment AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPBill
WHERE intTransactionType = 2
AND ISNULL(ysnPosted, 0) = 0
UNION ALL
SELECT 'Basis Advance' AS strTransactionType,
       intBillId,
       strBillId,
       dblTotal,
       strVendorOrderNumber,
       intEntityVendorId,
       intEntityId,
       dtmDate,
       strComment AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPBill
WHERE intTransactionType = 13
AND ISNULL(ysnPosted, 0) = 0
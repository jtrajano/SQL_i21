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
UNION ALL
SELECT 'Payable' AS strTransactionType,
       intPaymentId,
       strPaymentRecordNum,
       dblAmountPaid,
       '' AS strVendorInvoiceNumber,
       intEntityVendorId AS intEntityVendorId,
       intEntityId,
       dtmDatePaid,
       strNotes AS strReference,
       NULL AS intCompanyLocationId
FROM tblAPPayment
WHERE (ysnPosted = 0 AND strPaymentInfo NOT LIKE 'Voided%')
UNION ALL
SELECT 'Debit Memo' AS strTransactionType,
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
WHERE intTransactionType = 3
  AND ISNULL(ysnPosted, 0) = 0
  AND intTransactionType != 6
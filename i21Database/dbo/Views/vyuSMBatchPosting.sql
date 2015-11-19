CREATE VIEW [dbo].[vyuSMBatchPosting]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY BatchPosting.dtmDate DESC) AS INT)	AS	intBatchPostingId, 
BatchPosting.strTransactionType		AS	strTransactionType, 
intJournalId						AS	intTransactionId, 
strJournalId						AS	strTransactionId, 
BatchPosting.intEntityId			AS	intEntityId, 
ISNULL(dblAmount, 0.0)				AS	dblAmount,
strVendorInvoiceNumber				AS	strVendorInvoiceNumber,
ISNULL(Entity.strName, '')			AS	strVendorName,
UserSecurity.strUserName			AS	strUserName,
BatchPosting.strDescription			AS	strDescription,
BatchPosting.dtmDate				AS	dtmDate,
CONVERT(NVARCHAR(100),Fiscal.guid)	AS  strFiscalUniqueId
FROM 
(
	SELECT Journal.strJournalType as strTransactionType, Journal.intJournalId, Journal.strJournalId, Total.dblDebit as dblAmount, '' as strVendorInvoiceNumber, null as intEntityVendorId, Journal.intEntityId, Journal.dtmDate, Journal.strDescription
	FROM tblGLJournal Journal CROSS APPLY(SELECT SUM(dblDebit) dblDebit FROM tblGLJournalDetail Detail WHERE Detail.intJournalId = Journal.intJournalId) Total 
	WHERE Journal.strJournalType IN ('Adjusted Origin Journal', 'General Journal', 'Audit Adjustment', 'Imported Journal', 'Origin Journal', 'Recurring Journal') AND Journal.strTransactionType <> 'Recurring' AND Journal.ysnPosted = 0
	UNION ALL
	SELECT 'Voucher', intBillId, strBillId, dblTotal, strVendorOrderNumber, intEntityVendorId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 1 AND intTransactionType != 6 AND ysnForApproval != 1 AND ISNULL(ysnPosted, 0) = 0 OR (dtmApprovalDate IS NOT NULL AND ysnApproved = 1)
	UNION ALL
	SELECT 'Payable', intPaymentId, strPaymentRecordNum, dblAmountPaid, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmDatePaid, strNotes as strReference FROM tblAPPayment WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Debit Memo', intBillId, strBillId, dblTotal, strVendorOrderNumber, intEntityVendorId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 3 AND ISNULL(ysnPosted, 0) = 0 AND intTransactionType != 6 
	UNION ALL
	SELECT strTransactionType, intInvoiceId, strInvoiceNumber, dblInvoiceTotal, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmDate, strComments FROM tblARInvoice WHERE strTransactionType IN ('Invoice', 'Credit Memo') AND ysnPosted = 0  AND ISNULL(intDistributionHeaderId, 0) = 0 AND ISNULL(ysnTemplate,0) = 0
	UNION ALL
	SELECT 'Payment', intPaymentId, strRecordNumber, dblAmountPaid, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmDatePaid, strNotes FROM tblARPayment WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Card Fueling', intTransactionId, strTransactionId, dblAmount, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmTransactionDate, strDescription FROM vyuCFBatchPostTransactions
) BatchPosting
LEFT JOIN tblEntity Entity ON BatchPosting.intEntityVendorId = Entity.intEntityId
INNER JOIN tblSMUserSecurity UserSecurity ON BatchPosting.intEntityId = UserSecurity.intEntityUserSecurityId
LEFT JOIN tblGLForBatchPosting Fiscal on BatchPosting.intJournalId = Fiscal.intTransactionId
GO
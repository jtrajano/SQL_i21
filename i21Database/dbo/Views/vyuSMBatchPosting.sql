CREATE VIEW [dbo].[vyuSMBatchPosting]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY BatchPosting.dtmDate DESC) AS INT)	AS	intBatchPostingId, 
BatchPosting.strTransactionType			AS	strTransactionType, 
intJournalId							AS	intTransactionId, 
strJournalId							AS	strTransactionId, 
BatchPosting.intEntityId				AS	intEntityId, 
ISNULL(BatchPosting.dblAmount, 0.0)		AS	dblAmount,
BatchPosting.strVendorInvoiceNumber		AS	strVendorInvoiceNumber,
BatchPosting.intEntityVendorId			AS  intEntityVendorId,
ISNULL(Entity.strName, '')				AS	strVendorName,
ISNULL(UserSecurity.strUserName, '')	AS	strUserName,
BatchPosting.strDescription				AS	strDescription,
BatchPosting.dtmDate					AS	dtmDate,
CONVERT(NVARCHAR(100),ISNULL(Fiscal.guid, ForBatchPosting.strBatchId))	AS  strFiscalUniqueId
FROM 
(
	SELECT Journal.strJournalType as strTransactionType, Journal.intJournalId, Journal.strJournalId, Total.dblDebit as dblAmount, '' as strVendorInvoiceNumber, null as intEntityVendorId, Journal.intEntityId, Journal.dtmDate, Journal.strDescription
	FROM tblGLJournal Journal CROSS APPLY(SELECT SUM(dblDebit) dblDebit FROM tblGLJournalDetail Detail WHERE Detail.intJournalId = Journal.intJournalId) Total 
	WHERE Journal.strJournalType IN ('Adjusted Origin Journal', 'General Journal', 'Audit Adjustment', 'Imported Journal', 'Origin Journal', 'Recurring Journal') AND Journal.strTransactionType <> 'Recurring' AND Journal.ysnPosted = 0
	UNION ALL
	SELECT 'Voucher', intBillId, strBillId, dblTotal, strVendorOrderNumber, intEntityVendorId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 1 AND intTransactionType != 6 AND ysnForApproval != 1 AND ISNULL(ysnPosted, 0) = 0 AND intBillId NOT IN (SELECT intBillId FROM tblAPBill WHERE (dtmApprovalDate IS NOT NULL AND ysnApproved = 0 AND ysnForApprovalSubmitted = 1))
	UNION ALL
	SELECT 'Payable', intPaymentId, strPaymentRecordNum, dblAmountPaid, '' as strVendorInvoiceNumber, intEntityVendorId as intEntityVendorId, intEntityId, dtmDatePaid, strNotes as strReference FROM tblAPPayment WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Debit Memo', intBillId, strBillId, dblTotal, strVendorOrderNumber, intEntityVendorId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 3 AND ISNULL(ysnPosted, 0) = 0 AND intTransactionType != 6 
	UNION ALL
	SELECT strTransactionType, intInvoiceId, strInvoiceNumber, dblInvoiceTotal, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmDate, strComments FROM tblARInvoice WHERE strTransactionType IN ('Invoice', 'Credit Memo') AND ysnPosted = 0  AND (ISNULL(intDistributionHeaderId, 0) = 0 AND ISNULL(intLoadDistributionHeaderId, 0) = 0) AND ISNULL(ysnRecurring,0) = 0 AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
	UNION ALL
	SELECT 'Payment', intPaymentId, strRecordNumber, dblAmountPaid, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmDatePaid, strNotes FROM tblARPayment WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Card Fueling', intTransactionId, strTransactionId, dblAmount, '' as strVendorInvoiceNumber, null as intEntityVendorId, intEntityId, dtmTransactionDate, strDescription FROM vyuCFBatchPostTransactions
	UNION ALL
	SELECT BankTranType.strBankTransactionTypeName, intTransactionId, strTransactionId, dblAmount, '' AS strVendorInvoiceNumber, NULL AS intEntityVendorId, intEntityId, dtmDate, strMemo
	FROM tblCMBankTransaction BankTran INNER JOIN tblCMBankTransactionType BankTranType ON BankTran.intBankTransactionTypeId = BankTranType.intBankTransactionTypeId
	WHERE ysnPosted = 0 AND strBankTransactionTypeName IN ('Bank Deposit', 'Bank Transaction', 'Misc Checks')
	UNION ALL
	SELECT 'Bank Transfer', intTransactionId, strTransactionId, dblAmount, '' AS strVendorInvoiceNumber, NULL AS intEntityVendorId, intEntityId, dtmDate, strDescription FROM tblCMBankTransfer WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Meter Reading', intMeterReadingId, strTransactionId, Total.dblNetPrice, '' AS strVendorInvoiceNumber, intEntityCustomerId, intEntityId, dtmTransaction, '' AS strDescription FROM vyuMBGetMeterReading Header CROSS APPLY(SELECT SUM(dblNetPrice) dblNetPrice FROM tblMBMeterReadingDetail Detail WHERE Detail.intMeterReadingId = Header.intMeterReadingId) Total WHERE ISNULL(ysnPosted, 0) = 0
) BatchPosting
LEFT JOIN tblEMEntity Entity ON BatchPosting.intEntityVendorId = Entity.intEntityId
LEFT JOIN tblSMUserSecurity UserSecurity ON BatchPosting.intEntityId = UserSecurity.intEntityUserSecurityId
LEFT JOIN tblGLForBatchPosting Fiscal on BatchPosting.intJournalId = Fiscal.intTransactionId
LEFT JOIN tblSMForBatchPosting ForBatchPosting on BatchPosting.intJournalId = ForBatchPosting.intTransactionId
GO
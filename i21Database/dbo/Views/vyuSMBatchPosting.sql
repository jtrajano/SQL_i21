﻿CREATE VIEW [dbo].[vyuSMBatchPosting]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY BatchPosting.dtmDate DESC) AS INT)	AS	intBatchPostingId, 
BatchPosting.strTransactionType					AS	strTransactionType, 
intJournalId						AS	intTransactionId, 
strJournalId						AS	strTransactionId, 
BatchPosting.intEntityId			AS	intEntityId, 
UserSecurity.strUserName			AS	strUserName,
BatchPosting.strDescription			AS	strDescription,
BatchPosting.dtmDate				AS	dtmDate,
CONVERT(NVARCHAR(100),Fiscal.guid)	AS  strFiscalUniqueId
FROM 
(
	SELECT strJournalType as strTransactionType, intJournalId, strJournalId, intEntityId, dtmDate, strDescription
	FROM tblGLJournal 
	WHERE strJournalType IN ('Adjusted Origin Journal', 'General Journal', 'Audit Adjustment', 'Imported Journal', 'Origin Journal', 'Recurring Journal') 
	AND strTransactionType <> 'Recurring'
	AND ysnPosted = 0
	UNION ALL
	SELECT 'Bill', intBillId, strBillId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 1 AND ISNULL(ysnPosted, 0) = 0 AND intTransactionType != 6 AND ysnForApproval != 1 AND (ysnApproved = 0 AND dtmApprovalDate IS NOT NULL) --WHERE ysnPosted = 0 AND ysnForApproval = 0 AND intTransactionType = 1
	UNION ALL
	SELECT 'Payable', intPaymentId, strPaymentRecordNum, intEntityId, dtmDatePaid, strNotes as strReference FROM tblAPPayment WHERE ysnPosted = 0
	UNION ALL
	SELECT 'Debit Memo', intBillId, strBillId, intEntityId, dtmDate, strComment as strReference FROM tblAPBill WHERE intTransactionType = 3 AND ISNULL(ysnPosted, 0) = 0 AND intTransactionType != 6 AND ysnForApproval != 1 AND (ysnApproved = 0 AND dtmApprovalDate IS NOT NULL) --ysnPosted = 0 AND ysnForApproval = 0 AND intTransactionType = 3
	UNION ALL
	SELECT strTransactionType, intInvoiceId, strInvoiceNumber, intEntityId, dtmDate, strComments FROM tblARInvoice WHERE strTransactionType IN ('Invoice', 'Credit Memo')
	AND ysnPosted = 0  AND ISNULL(intDistributionHeaderId, 0) = 0 AND ISNULL(ysnTemplate,0) = 0
	UNION ALL
	SELECT 'Payment', intPaymentId, strRecordNumber, intEntityId, dtmDatePaid, strNotes FROM tblARPayment WHERE ysnPosted = 0
) BatchPosting
INNER JOIN tblSMUserSecurity UserSecurity ON BatchPosting.intEntityId = UserSecurity.[intEntityUserSecurityId]
LEFT JOIN tblGLForBatchPosting Fiscal on BatchPosting.intJournalId = Fiscal.intTransactionId
GO
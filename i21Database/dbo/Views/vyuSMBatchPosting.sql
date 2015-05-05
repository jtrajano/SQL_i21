CREATE VIEW [dbo].[vyuSMBatchPosting]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS INT)	AS	intBatchPostingId, 
strTransactionType					AS	strTransactionType, 
intJournalId						AS	intTransactionId, 
strJournalId						AS	strTransactionId, 
BatchPosting.intEntityId			AS	intEntityId, 
UserSecurity.strUserName			AS	strUserName,
strDescription						AS	strDescription,
dtmDate								AS	dtmDate
FROM 
(
	SELECT strJournalType as strTransactionType, intJournalId, strJournalId, intEntityId, dtmDate, strDescription
	FROM tblGLJournal 
	WHERE strJournalType IN ('Adjusted Origin Journal', 'General Journal', 'Audit Adjustment', 'Imported Journal', 'Origin Journal', 'Recurring Journal' ) 
	AND ysnPosted = 0
	--UNION ALL
	--SELECT 'Bill', intBillId, strBillId, intEntityId, dtmDate, NULL as strReference FROM tblAPBill WHERE ysnPosted = 0
) BatchPosting
INNER JOIN tblSMUserSecurity UserSecurity ON BatchPosting.intEntityId = UserSecurity.intEntityId
GO
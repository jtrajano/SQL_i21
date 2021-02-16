CREATE VIEW dbo.vyuGLUnpostedTransaction
AS
SELECT  strTransactionId, dtmDate ,'Inventory' strModule from [vyuICGetUnpostedTransactions] vyuICGetUnpostedTransactions 
UNION SELECT  strTransactionId, dtmDate , 'Payroll'  from vyuPRUnpostedTransactions 
UNION SELECT  strBillId strTransactionId, dtmDate, 'Purchasing'  FROM [vyuAPBatchPostTransaction] 
UNION SELECT  strTransactionId, dtmDate, 'Sales' FROM [vyuARBatchPosting]
UNION SELECT  strTransactionId, dtmTransactionDate dtmDate, 'Card Fueling' FROM vyuCFBatchPostTransactions 
UNION SELECT  strTransactionId, dtmDate, 'Cash Management' FROM vyuCMUnpostedTransaction 
UNION SELECT  strJournalId strTransactionId, dtmDate, 'General Journal'  FROM tblGLJournal 
    WHERE ysnPosted = 0 and (strTransactionType = 'General Journal' OR strTransactionType = 'Audit Adjustment')

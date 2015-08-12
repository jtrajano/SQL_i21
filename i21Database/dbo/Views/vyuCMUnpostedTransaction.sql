CREATE VIEW [dbo].[vyuCMUnpostedTransaction]
AS 

SELECT 
intTransactionId
,strTransactionId
,strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BT.intBankTransactionTypeId)
,dtmDate
FROM tblCMBankTransaction BT
WHERE ISNULL(ysnPosted,0) = 0

CREATE VIEW [dbo].[vyuCMBankLoanDetail] AS
SELECT 
T.intTransactionId,
T.intBankTransactionTypeId,
P.strBankTransactionTypeName,
T.strTransactionId,
L.intBankLoanId,
T.dtmDate,
T.dblAmount,
T.strMemo,
T.intConcurrencyId
FROM tblCMBankLoan L
JOIN tblCMBankTransaction T
ON L.intBankLoanId = T.intBankLoanId
JOIN tblCMBankAccount BA 
ON BA.intBankAccountId=T.intBankAccountId
LEFT JOIN
tblCMBankTransactionType P
ON P.intBankTransactionTypeId = T.intBankTransactionTypeId
WHERE T.ysnPosted = 1
GO


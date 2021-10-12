CREATE VIEW [dbo].[vyuCMBankLoanDetail] AS
SELECT 
D.intTransactionDetailId,
D.intTransactionId,
T.intBankTransactionTypeId,
strGLAccountIdDetail = A.strAccountId,
P.strBankTransactionTypeName,
intGLAccountIdDetail = D.intGLAccountId,
T.strTransactionId,
L.intBankLoanId,
T.dtmDate,
detail.dblCredit,
T.strMemo,
T.ysnPosted,
T.intConcurrencyId
FROM tblCMBankLoan L
JOIN tblCMBankTransaction T
ON L.intBankLoanId = T.intBankLoanId
LEFT JOIN tblCMBankTransactionDetail D
ON D.intTransactionId = T.intTransactionId
LEFT JOIN tblGLAccount A
on A.intAccountId = D.intGLAccountId
LEFT JOIN
tblCMBankTransactionType P
ON P.intBankTransactionTypeId = T.intBankTransactionTypeId
OUTER APPLY(
SELECT sum(dblCredit - dblDebit) dblCredit FROM tblCMBankTransactionDetail WHERE intTransactionId = T.intTransactionId
) detail
GO


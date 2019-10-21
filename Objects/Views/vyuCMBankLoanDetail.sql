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
detailDebit.dblDebit,
T.strMemo,
T.ysnPosted,
T.intConcurrencyId
FROM tblCMBankLoan L
LEFT JOIN tblCMBankTransaction T
on L.intBankLoanId = T.intBankLoanId
LEFT JOIN tblCMBankTransactionDetail D
ON D.intTransactionId = T.intTransactionId
LEFT JOIN tblGLAccount A
on A.intAccountId = D.intGLAccountId
LEFT JOIN
tblCMBankTransactionType P
on P.intBankTransactionTypeId = T.intBankTransactionTypeId
outer apply(
select sum(dblDebit -dblCredit ) dblDebit from tblCMBankTransactionDetail where intTransactionId = T.intTransactionId
) detailDebit
GO


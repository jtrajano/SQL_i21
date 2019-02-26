CREATE VIEW [dbo].[vyuCMBankLoan]
AS
SELECT 
L.*,
T.intBankAccountId,
T.strTransactionId,
BA.strBankAccountNo,
U.dblBalance,
intGLLoanAccountId = D.intGLAccountId,
strGLLoanAccountId = GL.strAccountId,
BA.strBankName,
BA.strCurrency,
T.intCurrencyId,
strStatus = CASE WHEN L.ysnOpen = 1 THEN  'Open' ELSE 'Closed' END COLLATE Latin1_General_CI_AS ,
T.ysnPosted
from tblCMBankLoan L 
JOIN tblCMBankTransaction T
ON L.intBankLoanId = L.intBankLoanId
LEFT JOIN tblCMBankTransactionDetail D
on D.intTransactionId = T.intTransactionId
LEFT JOIN tblGLAccount GL 
ON GL.intAccountId = D.intGLAccountId
LEFT JOIN vyuCMBankAccount BA
ON BA.intBankAccountId = T.intBankAccountId
CROSS APPLY
(
	SELECT SUM(dblAmount) dblBalance from tblCMBankTransaction WHERE intBankLoanId = L.intBankLoanId 
)U
WHERE
T.intBankTransactionTypeId = 52
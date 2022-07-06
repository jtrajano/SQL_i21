CREATE VIEW [dbo].[vyuCMBankLoan]
as
SELECT 
L.strBankLoanId,
L.intBankLoanId,
L.dtmOpened,
L.dtmMaturity,
L.dtmEntered,
L.decAnnualInterest,
L.ysnOpen,
L.strComments,
L.intConcurrencyId,
dblLoanAmount = V.dblBalance,
V.intBankAccountId,
V.strTransactionId,
V.strBankAccountNo,
U.dblBalance,
intGLLoanAccountId = V.intGLAccountId,
strGLLoanAccountId = V.strAccountId,
V.strBankName,
V.strCurrency,
T.intCurrencyId,
strStatus = CASE WHEN L.ysnOpen = 1 THEN  'Open' ELSE 'Closed' END COLLATE Latin1_General_CI_AS ,
T.ysnPosted
from tblCMBankLoan L 
JOIN tblCMBankTransaction T
ON L.intBankLoanId = T.intBankLoanId
AND intBankTransactionTypeId = 52
CROSS APPLY
(
	SELECT SUM(BB.dblCredit - BB.dblDebit) dblBalance 
	from tblCMBankTransaction AA join tblCMBankTransactionDetail BB
	on AA.intTransactionId = BB.intTransactionId
	WHERE AA.intBankLoanId = L.intBankLoanId 
)U
CROSS APPLY
(
	SELECT SUM(DD.dblCredit - DD.dblDebit) dblBalance, FF.strAccountId, EE.strBankAccountNo, CC.intBankAccountId, CC.strTransactionId, EE.strBankName
	,EE.strCurrency, EE.intCurrencyId,DD.intGLAccountId
	from tblCMBankTransaction CC 
	join tblCMBankTransactionDetail DD	on CC.intTransactionId = DD.intTransactionId
	join vyuCMBankAccount EE on EE.intBankAccountId = CC.intBankAccountId
	join tblGLAccount FF on DD.intGLAccountId = FF.intAccountId
	
	 WHERE CC.intBankLoanId = L.intBankLoanId 
	 AND CC.intBankTransactionTypeId = 52
	 GROUP BY CC.intBankAccountId,EE.strBankAccountNo,DD.intGLAccountId, FF.strAccountId, CC.strTransactionId,EE.strCurrency, EE.intCurrencyId, EE.strBankName
)V


GO


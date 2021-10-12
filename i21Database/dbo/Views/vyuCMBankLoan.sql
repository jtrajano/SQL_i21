CREATE VIEW [dbo].[vyuCMBankLoan]  
AS
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
L.intBankAccountId,  
V.strTransactionId,  
BA.strBankAccountNo,  
U.dblBalance,  
intGLLoanAccountId = BA.intGLAccountId,  
strGLLoanAccountId = BA.strGLAccountId,  
BA.strBankName,  
BA.strCurrency,  
T.intCurrencyId,  
strStatus = CASE WHEN L.ysnOpen = 1 THEN  'Open' ELSE 'Closed' END COLLATE Latin1_General_CI_AS ,  
T.ysnPosted  
FROM tblCMBankLoan L   
LEFT JOIN tblCMBankTransaction T  
ON L.intBankLoanId = T.intBankLoanId  
AND intBankTransactionTypeId = 52  
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
OUTER APPLY  
(  
 SELECT SUM(BB.dblCredit - BB.dblDebit) dblBalance   
 FROM tblCMBankTransaction AA JOIN tblCMBankTransactionDetail BB  
 on AA.intTransactionId = BB.intTransactionId  
 WHERE AA.intBankLoanId = L.intBankLoanId   
)U  
OUTER APPLY  
(  
 SELECT SUM(DD.dblCredit - DD.dblDebit) dblBalance, FF.strAccountId, 
 CC.strTransactionId, DD.intGLAccountId  
 FROM tblCMBankTransaction CC   
 JOIN tblCMBankTransactionDetail DD on CC.intTransactionId = DD.intTransactionId  
 JOIN vyuCMBankAccount EE on EE.intBankAccountId = CC.intBankAccountId  
 JOIN tblGLAccount FF on DD.intGLAccountId = FF.intAccountId  
   
  WHERE CC.intBankLoanId = L.intBankLoanId   
  AND CC.intBankTransactionTypeId = 52  
  GROUP BY DD.intGLAccountId, FF.strAccountId, CC.strTransactionId
)V
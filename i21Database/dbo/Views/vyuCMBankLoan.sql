CREATE VIEW [dbo].[vyuCMBankLoan]  
AS
SELECT   
L.*,
V.strTransactionId,  
BA.strBankAccountNo,  
U.dblBalance,  
intGLLoanAccountId = BA.intGLAccountId,  
strGLLoanAccountId = BA.strGLAccountId,  
BA.strBankName,  
BA.strCurrency,  
T.intCurrencyId,  
strStatus = CASE WHEN L.ysnOpen = 1 THEN  'Open' ELSE 'Closed' END COLLATE Latin1_General_CI_AS,  
T.ysnPosted,
strLimitType=
CASE 
  WHEN intLimitTypeId =1 THEN 'Contract'
  WHEN intLimitTypeId =2 THEN 'Logistics'
  WHEN intLimitTypeId =3 THEN 'Payables'
  WHEN intLimitTypeId =4 THEN 'Receivables'
  WHEN intLimitTypeId =5 THEN 'Total'
END,
strLoanType=
CASE 
  WHEN intLoanTypeId = 1 THEN 'Bank Loan'
  WHEN intLoanTypeId = 2 THEN 'Trade Limit'
END,
strBorrowingFacilityId
FROM tblCMBankLoan L   
LEFT JOIN tblCMBankTransaction T  
ON L.intBankLoanId = T.intBankLoanId  
AND intBankTransactionTypeId = 52  
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
LEFT JOIN tblCMBorrowingFacility BF ON BF.intBorrowingFacilityId = L.intBorrowingFacilityId
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
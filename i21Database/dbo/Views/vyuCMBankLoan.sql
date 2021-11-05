CREATE VIEW [dbo].[vyuCMBankLoan]  
AS
SELECT   
L.*,
BA.strBankAccountNo,  
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
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
LEFT JOIN tblCMBorrowingFacility BF ON BF.intBorrowingFacilityId = L.intBorrowingFacilityId
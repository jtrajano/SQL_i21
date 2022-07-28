CREATE VIEW [dbo].[vyuCMBankLoan]  
AS
SELECT   
L.*,
BA.strBankAccountNo,  
BA.strBankName,  
BA.strCurrency,  
BA.intBankId,
strStatus = CASE WHEN L.ysnOpen = 1 THEN  'Open' ELSE 'Closed' END COLLATE Latin1_General_CI_AS,  
strLimitType=
CASE 
  WHEN intLimitTypeId =1 THEN 'Contract'
  WHEN intLimitTypeId =2 THEN 'Logistics'
  WHEN intLimitTypeId =3 THEN 'Payables'
  WHEN intLimitTypeId =4 THEN 'Receivables'
  WHEN intLimitTypeId =5 THEN 'Total'
END COLLATE Latin1_General_CI_AS,
strLoanType=
CASE 
  WHEN intLoanTypeId = 1 THEN 'Bank Loan'
  WHEN intLoanTypeId = 2 THEN 'Trade Limit'
END COLLATE Latin1_General_CI_AS,
strBorrowingFacilityId,
ISNULL(Detail.ysnHasFunds, CAST(0 AS BIT)) ysnHasFunds
FROM tblCMBankLoan L
OUTER APPLY(
  SELECT TOP 1 CAST(1 AS BIT) ysnHasFunds FROM vyuCMBankLoanDetail WHERE intBankTransactionTypeId = 10
  AND intBankLoanId = L.intBankLoanId
)Detail
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
LEFT JOIN tblCMBorrowingFacility BF ON BF.intBorrowingFacilityId = L.intBorrowingFacilityId
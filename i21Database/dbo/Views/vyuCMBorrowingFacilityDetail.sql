  
CREATE VIEW [dbo].[vyuCMBorrowingFacilityDetail]  
AS  
SELECT A.*,  
B.strBankAccountNo,  
B.strCurrency strBankAccountCurrency,  
B.strLimitType,  
B.strLoanType,  
B.dblHaircut,  
B.dblLimit,  
dblFacilityLimit =   dblRate * dblLimit,
B.intMaturityDays,  
B.strBankLoanId,  
B.intDaysInCycle  
FROM tblCMBorrowingFacilityDetail A  
LEFT JOIN vyuCMBankLoan B ON B.intBankLoanId = A.intBankLoanId  
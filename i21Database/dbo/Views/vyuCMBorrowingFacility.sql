CREATE VIEW [dbo].[vyuCMBorrowingFacility]
AS
SELECT A.*, 
B.strBankName,
C.strCurrency strPositionCurrency,
strBankValuationRule
FROM tblCMBorrowingFacility A
LEFT JOIN tblCMBank B ON B.intBankId = A.intBankId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = A.intPositionCurrencyId
LEFT JOIN tblCMBankValuationRule D ON D.intBankValuationRuleId = A.intBankValuationRuleId
GO
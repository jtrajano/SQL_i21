
CREATE VIEW [dbo].[vyuCMBorrowingFacilityDetail]
AS
SELECT A.*,
strBankAccountNo,
D.strCurrency strBankAccountCurrency,
C.strLimitType
FROM tblCMBorrowingFacilityDetail A
LEFT JOIN tblCMBankAccount B ON B.intBankAccountId = A.intBankAccountId
LEFT JOIN tblCMTradeFinanceLimitType C ON C.intLimitTypeId = A.intTradeTypeLimitId
LEFT JOIN tblSMCurrency D on D.intCurrencyID = B.intCurrencyId
GO



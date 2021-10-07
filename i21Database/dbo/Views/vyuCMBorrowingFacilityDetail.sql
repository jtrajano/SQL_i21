CREATE VIEW vyuCMBorrowingFacilityDetail
AS
SELECT A.*,
strBankAccountNo,
C.strLimitType
FROM tblCMBorrowingFacilityDetail A
LEFT JOIN tblCMBankAccount B ON B.intBankAccountId = A.intBankAccountId
LEFT JOIN tblCMTradingFinanceLimitType C ON C.intLimitTypeId = A.intTradeTypeLimitId

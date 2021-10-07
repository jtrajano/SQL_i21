CREATE VIEW vyuCMBorrowingFacility
AS
SELECT A.*, B.strBankName,
C.strCurrency strPositionCurrency
from tblCMBorrowingFacility A
left join
tblCMBank B ON B.intBankId = A.intBankId
LEFT JOIN tblSMCurrency C ON 
C.intCurrencyID = A.intPositionCurrencyId

CREATE VIEW vyuCMResponsiblePartyMatching
AS
select
A.*,
D.intResponsibleEntityId,
strAction =
CASE
WHEN A.intActionId = 1 THEN 'Notify Only'  
WHEN A.intActionId = 2 THEN 'Clear Check'  
WHEN A.intActionId = 3 THEN 'Create Bank Transfer'  
WHEN A.intActionId = 4 THEN 'Create Bank Deposit'  
WHEN A.intActionId = 5 THEN 'Clear Bank Deposit'
WHEN A.intActionId = 6 THEN 'Clear Bank Withdrawal'
ELSE 'ignore'
END,
C.strAccountId strPrimaryAccount,
D.strBankAccountNo strPrimaryBank,
E.strBankAccountNo strOffsetBank
from tblCMResponsiblePartyMatching A
left join tblGLAccount C on C.intAccountId = A.intPrimaryAccountId
left join vyuCMBankAccount D on D.intBankAccountId = A.intPrimaryBankId
left join vyuCMBankAccount E on E.intBankAccountId = A.intOffsetBankId
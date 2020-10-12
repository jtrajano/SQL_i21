CREATE VIEW vyuCMResponsiblePartyMatching
AS
select
A.*,
strAction =
CASE
WHEN A.intActionId = 1 THEN 'Notify Only'
WHEN A.intActionId = 2 THEN 'Clear Check'
WHEN A.intActionId = 3 THEN 'Bank Transfer'
WHEN A.intActionId = 4 THEN 'Bank Deposit'
ELSE 'ignore'
END,
C.strCode strPrimarySegment,
D.strBankAccountNo strPrimaryBank,
E.strBankAccountNo strOffsetBank
from tblCMResponsiblePartyMatching A
left join tblGLAccountSegment C on C.intAccountSegmentId = A.intPrimarySegmentId
left join vyuCMBankAccount D on D.intBankAccountId = A.intPrimaryBankId
left join vyuCMBankAccount E on E.intBankAccountId = A.intOffsetBankId
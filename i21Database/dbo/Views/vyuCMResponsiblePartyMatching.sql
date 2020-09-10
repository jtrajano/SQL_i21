CREATE VIEW vyuCMResponsiblePartyMatching
AS
select 
A.intResponsiblePartyMatchingId,
A.strType,
A.strDescriptionContains,
A.strAccountNumberContains,
A.strReferenceContains,
A.strAction,
A.intPrimaryBankId,
A.intOffsetBankId,
A.intLocationSegmentId,
A.intPrimarySegmentId,
A.intConcurrencyId,
B.strCode strLocationSegment,
C.strCode strPrimarySegment,
D.strBankAccountNo strPrimaryBank,
E.strBankAccountNo strOffsetBank
from tblCMResponsiblePartyMatching A
left join tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
left join tblGLAccountSegment C on C.intAccountSegmentId = A.intPrimarySegmentId
left join vyuCMBankAccount D on D.intBankAccountId = A.intPrimaryBankId
left join vyuCMBankAccount E on E.intBankAccountId = A.intOffsetBankId

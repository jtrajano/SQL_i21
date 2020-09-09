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
B.strCode strLocationSegment,
C.strCode strPrimarySegment,
D.strBankName strPrimaryBank,
E.strBankName strOffsetBank
from tblCMResponsiblePartyMatching A
left join tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
left join tblGLAccountSegment C on C.intAccountSegmentId = A.intPrimarySegmentId
left join tblCMBank D on D.intBankId = A.intPrimaryBankId
left join tblCMBank E on E.intBankId = A.intOffsetBankId

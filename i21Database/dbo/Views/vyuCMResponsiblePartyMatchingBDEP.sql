CREATE VIEW vyuCMResponsiblePartyMatchingBDEP
AS
select 
A.*,
B.strCode strLocationSegment
from tblCMResponsiblePartyMatchingBDEP A
left join tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
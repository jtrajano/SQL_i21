CREATE VIEW [dbo].[vyuCMResponsiblePartyMatchingBDEP]
AS
SELECT
A.intResponsiblePartyMatchingBDEPId,
A.intResponsiblePartyMatchingId,
A.intLocationSegmentId,
A.strContains,
A.intAccountId,
B.strCode strLocationSegment,
A.intConcurrencyId
FROM tblCMResponsiblePartyMatchingBDEP A
LEFT JOIN tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
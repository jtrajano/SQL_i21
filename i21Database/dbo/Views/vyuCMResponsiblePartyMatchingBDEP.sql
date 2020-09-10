CREATE VIEW [dbo].[vyuCMResponsiblePartyMatchingBDEP]
AS
SELECT 
A.[intResponsiblePartyMatchingBDepId],
A.[intResponsiblePartyMatchingId],
A.[intLocationSegmentId],
A.[strContains],
A.[intConcurrencyId],
B.strCode strLocationSegment
FROM tblCMResponsiblePartyMatchingBDEP A
LEFT JOIN tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
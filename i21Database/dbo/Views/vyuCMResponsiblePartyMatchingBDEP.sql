CREATE VIEW [dbo].[vyuCMResponsiblePartyMatchingBDEP]
AS
SELECT 
A.*,
B.strCode strLocationSegment
FROM tblCMResponsiblePartyMatchingBDEP A
LEFT JOIN tblGLAccountSegment B on B.intAccountSegmentId = A.intLocationSegmentId
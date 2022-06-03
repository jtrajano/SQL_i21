CREATE VIEW dbo.[vyuGLSegmentMapping]
AS
SELECT
A.intAccountSegmentId,
S.intAccountId,
A.strCode,
A.strDescription,
D.strAccountId,
C.intSegmentTypeId
FROM tblGLAccountSegmentMapping S 
JOIN tblGLAccount D on D.intAccountId = S.intAccountId
JOIN tblGLAccountSegment A ON A.intAccountSegmentId = S.intAccountSegmentId
JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
JOIN tblGLSegmentType C ON C.intSegmentTypeId = B.intStructureType
GO
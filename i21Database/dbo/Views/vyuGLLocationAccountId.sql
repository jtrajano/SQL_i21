CREATE VIEW dbo.vyuGLLocationAccountId
AS
SELECT
A.intAccountSegmentId,
S.intAccountId,
A.strCode,
A.strDescription,
S.strAccountId
FROM tblGLTempCOASegment S 
JOIN tblGLAccountSegment A
ON S.[Location] = A.strCode
JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
WHERE B.strStructureName = 'Location'


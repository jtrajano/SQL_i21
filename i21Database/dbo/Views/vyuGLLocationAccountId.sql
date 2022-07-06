CREATE VIEW dbo.vyuGLLocationAccountId
AS
SELECT
A.intAccountSegmentId,
S.intAccountId,
A.strCode,
A.strDescription,
S.strAccountId COLLATE Latin1_General_CI_AS strAccountId
FROM tblGLTempCOASegment S 
JOIN tblGLAccountSegment A
ON S.[Location] COLLATE Latin1_General_CI_AS = A.strCode
JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
WHERE B.strStructureName = 'Location'


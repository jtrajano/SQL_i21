CREATE VIEW dbo.vyuGLCompanyAccountId
AS
SELECT
A.intAccountSegmentId,
S.intAccountId,
A.strCode,
A.strDescription,
S.strAccountId COLLATE Latin1_General_CI_AS strAccountId,
B.strStructureName
FROM tblGLTempCOASegment S 
JOIN tblGLAccountSegment A
ON S.[Company] COLLATE Latin1_General_CI_AS = A.strCode
JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
WHERE B.strStructureName = 'Company'


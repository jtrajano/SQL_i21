/*
    Dummy view
    Will be modified in post-deployment
*/
CREATE VIEW dbo.vyuGLCompanyAccountId
AS
SELECT
A.intAccountSegmentId,
0 intAccountId ,
A.strCode,
A.strDescription,
'' COLLATE Latin1_General_CI_AS strAccountId,
B.strStructureName
FROM 
tblGLAccountSegment A
JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
WHERE B.strStructureName = 'Company'


CREATE PROCEDURE uspGLUpdateAccountLocationId
AS
UPDATE A set intLocationSegmentId = S.intAccountSegmentId FROM tblGLAccount A JOIN tblGLAccountSegmentMapping M on A.intAccountId = M.intAccountId
JOIN tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId =  S.intAccountStructureId
WHERE intStructureType = 3
AND intLocationSegmentId IS NULL


UPDATE A set intCompanySegmentId = S.intAccountSegmentId FROM tblGLAccount A JOIN tblGLAccountSegmentMapping M on A.intAccountId = M.intAccountId
JOIN tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId =  S.intAccountStructureId
WHERE intStructureType = 6
AND intCompanySegmentId IS NULL


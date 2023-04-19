CREATE PROCEDURE uspGLUpdateAccountSegmentId
AS
UPDATE A set intLocationSegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 3)S
WHERE intLocationSegmentId IS NULL

UPDATE A set intLOBSegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 5)S
WHERE intLOBSegmentId IS NULL

UPDATE A set intCompanySegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 6)S
WHERE intCompanySegmentId IS NULL

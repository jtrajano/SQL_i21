CREATE PROCEDURE uspGLUpdateAccountSegmentId
AS
UPDATE A set intLocationSegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 3)S
WHERE intLocationSegmentId IS NULL

UPDATE A set intLOBSegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 5)S
WHERE intLOBSegmentId IS NULL

UPDATE A set intCompanySegmentId = S.intAccountSegmentId FROM tblGLAccount A OUTER APPLY fnGLGetSegmentAccount(A.intAccountId, 6)S
WHERE intCompanySegmentId IS NULL


-- FOR range query
;WITH cte AS (

    SELECT ROW_NUMBER() OVER(ORDER BY strAccountId ASC) rowId, intAccountId FROM tblGLAccount
)
UPDATE A SET intOrderId = rowId FROM tblGLAccount A JOIN cte B ON A.intAccountId = B.intAccountId

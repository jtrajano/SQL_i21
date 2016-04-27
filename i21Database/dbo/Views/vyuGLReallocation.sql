CREATE VIEW [dbo].[vyuGLReallocation]
AS
     SELECT
             RA.intAccountReallocationId, RA.strName, RA.strDescription AS strDescription, A.strAccountId, A.strDescription as strAccountIdDescription, ISNULL(dblPercentage, 0) AS dblPercentage
     FROM tblGLAccountReallocationDetail AAD
          INNER JOIN tblGLAccount A ON AAD.intAccountId = A.intAccountId
          INNER JOIN tblGLAccountReallocation RA ON AAD.intAccountReallocationId = RA.intAccountReallocationId
CREATE PROCEDURE [dbo].[uspGLSyncGLAccountDescription]
	@intAccountSegmentId int
AS
DECLARE @tbl TABLE 
(
	intAccountId INT
)
INSERT INTO @tbl
	SELECT intAccountId FROM tblGLAccountSegmentMapping WHERE intAccountSegmentId = @intAccountSegmentId

;WITH CTE(intAccountId,strDescription) AS(

	SELECT A1.intAccountId,
	   STUFF(( 
	   SELECT  ' - ' +  RTRIM(S.strDescription)
		FROM         dbo.tblGLAccountSegment S INNER JOIN
						  dbo.tblGLAccountSegmentMapping M ON S.intAccountSegmentId = M.intAccountSegmentId 
						  RIGHT OUTER JOIN
						  dbo.tblGLAccount A2 ON M.intAccountId = A2.intAccountId 
						  
						  WHERE A2.intAccountId = A1.intAccountId
						  
			FOR XML PATH('') )  
		, 1, 2, '' ) AS strDescription
FROM tblGLAccount A1  
JOIN @tbl A3 ON A3.intAccountId = A1.intAccountId
GROUP BY A1.intAccountId)

UPDATE A SET A.strDescription = ISNULL(CTE.strDescription ,'')
FROM tblGLAccount A INNER JOIN CTE ON A.intAccountId = CTE.intAccountId

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
UPDATE G SET G.glact_desc = SUBSTRING(ISNULL(A.strDescription,''),1,30)
FROM tblGLAccount A 
JOIN @tbl S ON S.intAccountId = A.intAccountId
JOIN tblGLCOACrossReference C ON C.inti21Id = A.intAccountId
JOIN glactmst G on G.A4GLIdentity = C.intLegacyReferenceId
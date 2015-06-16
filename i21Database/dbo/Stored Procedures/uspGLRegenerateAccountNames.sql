--Author		: Trajano, Jeffrey
--Date			: 06-16-2015
--Description	: Regenerate Names in Chart Of Accounts using a specific string delimiter
CREATE PROCEDURE uspGLRegenerateAccountNames(@strDelimiter  NVARCHAR(1) = ' ')
AS
BEGIN
	IF @strDelimiter = '' SET @strDelimiter = ' '
	;WITH CTE(intAccountId,strDescription) 
	AS(
	SELECT A1.intAccountId,
	   STUFF(( 
	   SELECT  @strDelimiter +  RTRIM(S.strDescription)
		FROM         dbo.tblGLAccountSegment S INNER JOIN
						  dbo.tblGLAccountSegmentMapping M ON S.intAccountSegmentId = M.intAccountSegmentId 
						  RIGHT OUTER JOIN
						  dbo.tblGLAccount A2 ON M.intAccountId = A2.intAccountId 
						  WHERE A2.intAccountId = A1.intAccountId
			FOR XML PATH('') )  
		, 1, 1, '' ) AS strDescription
    FROM tblGLAccount A1  
	GROUP BY intAccountId)
	UPDATE A SET A.strDescription = CTE.strDescription  FROM tblGLAccount A INNER JOIN CTE ON A.intAccountId = CTE.intAccountId
END
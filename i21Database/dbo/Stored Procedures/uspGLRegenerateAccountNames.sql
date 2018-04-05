--Author		: Trajano, Jeffrey
--Date			: 06-16-2015
--Description	: Regenerate Names in Chart Of Accounts using a specific string delimiter
CREATE PROCEDURE [dbo].[uspGLRegenerateAccountNames](@strDelimiter  NVARCHAR(1) = ' ')
AS
BEGIN
	IF @strDelimiter = '' SET @strDelimiter = ' '
	UPDATE tblGLAccountSegment SET strDescription = NULL WHERE RTRIM (strDescription) = ''
	;WITH CTE(intAccountId,strDescription) 
	AS(
	SELECT A1.intAccountId,
	   STUFF(( 
	   SELECT  ' ' + @strDelimiter + ' ' +  RTRIM(S.strDescription)
		FROM         dbo.tblGLAccountSegment S INNER JOIN
						  dbo.tblGLAccountSegmentMapping M ON S.intAccountSegmentId = M.intAccountSegmentId 
						  JOIN tblGLAccountStructure St on S.intAccountStructureId = St.intAccountStructureId
						  RIGHT OUTER JOIN dbo.tblGLAccount A2 ON M.intAccountId = A2.intAccountId 
						  WHERE A2.intAccountId = A1.intAccountId
						  ORDER BY St.intSort
			FOR XML PATH('') )  
		, 1, 2, '' ) AS strDescription
    FROM tblGLAccount A1  
	GROUP BY intAccountId)
	UPDATE A SET A.strDescription = ISNULL(CTE.strDescription ,'')
	 FROM tblGLAccount A INNER JOIN CTE ON A.intAccountId = CTE.intAccountId
	 INNER JOIN tblGLAccountSegmentMapping M ON A.intAccountId = M.intAccountId
	 INNER JOIN tblGLAccountSegment S ON M.intAccountSegmentId = S.intAccountSegmentId
	 IF @strDelimiter <> ''
	 BEGIN
		UPDATE tblGLAccount SET strDescription = SUBSTRING(RTRIM(strDescription),0,LEN(strDescription)-1)
		WHERE SUBSTRING(RTRIM(strDescription),LEN(strDescription),1) = @strDelimiter
	 END
END
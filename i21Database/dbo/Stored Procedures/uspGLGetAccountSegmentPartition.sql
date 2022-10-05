CREATE PROCEDURE [dbo].[uspGLGetAccountSegmentPartition]
AS
DECLARE 
	@cols NVARCHAR(MAX)
    ,@stmt NVARCHAR(MAX)

SELECT @cols = ISNULL(@cols + ', ', '') + '[' + T.strStructureName + ']' FROM (
	SELECT DISTINCT TOP 100 strStructureName, intSort 
	FROM tblGLAccountStructure 
	WHERE strType <> 'Divider' 
	ORDER BY intSort ) AS T

SELECT @stmt = 'SELECT TOP 10 '+@cols+', strDescription, ISNULL(strUOMCode, '''') strUOMCode
	FROM (
		SELECT 
			B.strCode
			,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN (''lob'', ''line of business'')) THEN ''LOB'' ELSE C.strStructureName END
			,D.strDescription
			,U.strUOMCode
		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		LEFT JOIN tblGLAccountUnit U on D.intAccountUnitId = U.intAccountUnitId
	) AS S
	PIVOT
	(
		MAX(strCode)
		FOR [strStructureName] IN (' + @cols + ')
	) AS PVT'

EXEC sp_executesql  @stmt = @stmt
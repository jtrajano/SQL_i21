GO
PRINT 'Begin Renaming tblGLTempCOASegment column Location to Location'
IF NOT EXISTS ( SELECT  TOP 1 1
            FROM    syscolumns
            WHERE   id = OBJECT_ID('tblGLTempCOASegment')
                    AND name = 'Location' ) 
BEGIN
	DECLARE @oldName varchar(150)
	SELECT  top 1 @oldName='tblGLTempCOASegment.' + name
				FROM    syscolumns
				WHERE   id = OBJECT_ID('tblGLTempCOASegment')
						AND name LIKE 'Location%'
	IF @oldName IS NOT NULL
		EXEC sp_rename @oldName, 'Location', 'COLUMN'
END
PRINT 'Finished Renaming tblGLTempCOASegment column Location to Location'

PRINT 'Begin Fixing Segment Categories'
IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountSegment where intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory))
BEGIN
	--not used in category but used in account table
	IF EXISTS(SELECT 1 FROM sys.columns 
	WHERE [name] = N'intAccountCategoryId' AND [object_id] = OBJECT_ID(N'tblGLAccount'))
	BEGIN
		declare @sqlStmt NVARCHAR(MAX) =
		'UPDATE t SET intAccountCategoryId =(
		select TOP 1 intAccountCategoryId FROM tblGLAccount where intAccountId =
		 (SELECT TOP 1  intAccountId from tblGLAccountSegmentMapping WHERE intAccountSegmentId = t.intAccountSegmentId ))
		FROM tblGLAccountSegment t
		WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory)
		AND intAccountSegmentId IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)'
		EXEC sp_executesql @sqlStmt
	END

	--not used in category and account table
	DECLARE @GeneralCategoryId INT
	SELECT @GeneralCategoryId = intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'General'
	UPDATE tblGLAccountSegment SET intAccountCategoryId = @GeneralCategoryId
	WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory)
	AND intAccountSegmentId NOT IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)
	
	
END
PRINT 'Finish Fixing Segment Categories'
GO
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
IF EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblSMBuildNumber' and type = 'U')
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblSMBuildNumber WHERE SUBSTRING ( strVersionNo ,0 , 5) > 15.1)
	BEGIN
		DECLARE @sqlStmt NVARCHAR(MAX) =
		'UPDATE t SET intAccountCategoryId =(
		select TOP 1 intAccountCategoryId FROM tblGLAccount where intAccountId =
			(SELECT TOP 1  intAccountId from tblGLAccountSegmentMapping WHERE intAccountSegmentId = t.intAccountSegmentId ))
		FROM tblGLAccountSegment t
		WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory)
		AND intAccountSegmentId IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)'
		EXEC sp_executesql @sqlStmt
			
		--not used in category and account table
		DECLARE @GeneralCategoryId INT
		SELECT @GeneralCategoryId = intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'General'

		SELECT @sqlStmt ='UPDATE tblGLAccountSegment SET intAccountCategoryId = ' + CAST( @GeneralCategoryId AS VARCHAR(3)) +
		' WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory) AND intAccountSegmentId NOT IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)'
		EXEC sp_executesql @sqlStmt
	END
END
PRINT 'Finish Fixing Segment Categories'
GO

PRINT 'Begin updating tblGLDetail null strTransactionType'
IF EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblGLDetail' and type = 'U')
BEGIN
		DECLARE @sqlStmt NVARCHAR(MAX)  = 'UPDATE tblGLDetail SET strTransactionType = ''Paycheck'' WHERE strTransactionForm = ''Paychecks'' AND strModuleName = ''Payroll'' AND strTransactionType IS NULL'
		EXEC sp_executesql @sqlStmt
		SELECT @sqlStmt = 'UPDATE tblGLDetail SET strTransactionType = strTransactionForm  WHERE strTransactionType IS NULL'
		EXEC sp_executesql @sqlStmt
END
PRINT 'Finished updating tblGLDetail null strTransactionType'
GO

--GL-2482
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE [TABLE_NAME] = 'vyuGLAccountView')
	BEGIN
		EXEC ('DROP VIEW vyuGLAccountView');
	END
Go

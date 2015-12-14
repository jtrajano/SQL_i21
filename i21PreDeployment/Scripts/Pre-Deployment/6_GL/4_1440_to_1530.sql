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
	BEGIN TRY
		declare @sqlStmt NVARCHAR(MAX) =
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

		SELECT @sqlStmt ='UPDATE tblGLAccountSegment SET intAccountCategoryId = ' + @GeneralCategoryId +
		' WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory) AND intAccountSegmentId NOT IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)'
		EXEC sp_executesql @sqlStmt
	END TRY
	BEGIN CATCH
		PRINT 'Fixing Segment Categories is not applicable :' + ERROR_MESSAGE()
	END CATCH
PRINT 'Finish Fixing Segment Categories'

PRINT 'Begin updating tblGLDetail null strTransactionType'

UPDATE tblGLDetail SET strTransactionType = 'Paycheck' WHERE strTransactionForm = 'Paychecks' AND strModuleName = 'Payroll' AND strTransactionType IS NULL
--update the remaining rows to strTransactionForm
UPDATE tblGLDetail SET strTransactionType = strTransactionForm  WHERE strTransactionType IS NULL

PRINT 'Finished updating tblGLDetail null strTransactionType'

GO
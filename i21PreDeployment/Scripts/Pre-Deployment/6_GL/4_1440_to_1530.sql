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

	EXEC sp_rename @oldName, 'Location', 'COLUMN'
END
PRINT 'Finished Renaming tblGLTempCOASegment column Location to Location'
GO
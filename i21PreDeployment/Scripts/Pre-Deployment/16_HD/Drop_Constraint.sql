
PRINT 'BEGIN Drop UNQ_tblHDModule'

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE name = 'UNQ_tblHDModule' AND type = 'UQ' AND parent_object_id = OBJECT_ID('tblHDModule', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblHDModule
		DROP CONSTRAINT UNQ_tblHDModule		
	');
END

GO
PRINT 'END Drop UNQ_tblHDModule'
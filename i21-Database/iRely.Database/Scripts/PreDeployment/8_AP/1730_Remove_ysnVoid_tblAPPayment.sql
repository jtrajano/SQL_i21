PRINT 'Checking tblAPPayment for ysnVoid'
IF(EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPPayment'  and [COLUMN_NAME] = 'ysnVoid' ))
BEGIN
	PRINT 'EXECUTE'
	
	declare @sql nvarchar(max)
	SELECT TOP 1 @sql = N'alter table tblAPPayment drop constraint [' + dc.name + N']'
		from sys.default_constraints dc
			JOIN sys.columns c
				ON c.default_object_id = dc.object_id
		WHERE 
			dc.parent_object_id = OBJECT_ID('tblAPPayment')
		AND c.name = N'ysnVoid'
    IF @@ROWCOUNT > 0
	BEGIN
		EXEC (@sql)
	END
	EXEC('
		ALTER TABLE tblAPPayment
		DROP COLUMN ysnVoid
	')
END
PRINT 'Done checking tblAPPayment for ysnVoid'